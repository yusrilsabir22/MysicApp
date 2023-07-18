//
//  PlayerViewModel.swift
//  mysic
//
//  Created by mac on 25/06/23.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI
import ffmpegkit
import MediaPlayer

enum PlaybackState {
    case play
    case pause
    case stop
    case converting
    case fetching
    case empty
    case finish
    

}

enum PlaybackMode: String, CaseIterable {
    case repeatOne
    case repeatAll
    case shuffle
    case normal
    case next
    
    var text: String {
        return rawValue.lowercased()
    }
}

@MainActor
class PlayerViewModel: ObservableObject {
    @Published var phase: PlaybackState = .empty
    @Published var currentTime: CMTime = CMTime()
    @Published var position: Double = 0
    @Published var duration: CMTime = CMTime()
    @Published var isPlaying: Bool = false
    @Published var song: Song?
    @Published var playbackMode: PlaybackMode = .repeatAll
    @Published var cacheInfo: String = "Cache | 0 Kb | 0 Song"

    private var index = 0
    private var playlist = [Song]()
    private var playURL = ""
    private var fetchDuration = 0
    
    var musicDir: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appending(path: "music")
    }
    
    private var mediaInfo = [String : Any]()
    
    private var player: AVPlayer = AVPlayer()
    private var playerItem: AVPlayerItem?
    
    
    private var cancellable: AnyCancellable?
    private var currentURL: URL?
    private var audioURL: String?
    
    private static let audioProcessingQueue = DispatchQueue(label: "audio-processing")
    
    private let mysicAPI = MysicAPI.shared
    
    init() {
        load()
    }
    
    
    private func fetchPlayerURL() async {
        if Task.isCancelled { return }
        phase = .fetching
        do {
            let player = try await mysicAPI.play(from: .play, params: QueryParams(id: song?.videoId))
            if Task.isCancelled { return }
            self.fetchDuration = Int(player.contentLength) ?? 0
            self.convertAudio(url: player.url)
        } catch {
            if Task.isCancelled { return }
            print("FETCH URL: \(error.localizedDescription)")
            return
        }
    }
    
    private func load() {
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: musicDir.path(), withIntermediateDirectories: true)
            getCache()
        } catch {
            print("ERROR READ/CREATE DIRECTORY: \(error.localizedDescription)")
        }
        
    }
    
    
    private func initPlayer(url: URL) {
        playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        Task.init {
            
            do {
                    
                if let dur = try await self.player.currentItem?.asset.load(.duration) {
                    self.duration = dur
                    mediaInfo[MPMediaItemPropertyPlaybackDuration] = dur.seconds
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
                }
            } catch {
                print("Failed to get duration")
            }
            
        }
        
        cancellable = player.periodicTimePublisher()
            .replaceError(with: CMTime(value: .zero, timescale: .zero))
            .receive(on: RunLoop.main)
            .subscribe(on: PlayerViewModel.audioProcessingQueue)
            .sink { [weak self] in self?.setCurrentTime($0) }
    }
    
    private func setupMediaPlayerNotifView() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        let cmdCenter = MPRemoteCommandCenter.shared()
        
        // add handler playing command
        cmdCenter.playCommand.addTarget { [unowned self] event in
            self.resume()
            return .success
        }
        
        cmdCenter.pauseCommand.addTarget { [unowned self] event in
            self.pause()
            return .success
        }
        cmdCenter.changePlaybackPositionCommand.addTarget {[unowned self] (remoteEvent) -> MPRemoteCommandHandlerStatus in
            if let event = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                self.player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
                self.player.play()
                isPlaying = true
                
            }
            return .success
        }
        
        cmdCenter.changeRepeatModeCommand.addTarget { [unowned self] event in
            playbackMode = .repeatOne
            return .success
        }
        
        cmdCenter.changeShuffleModeCommand.addTarget { [unowned self] event in
            playbackMode = .repeatAll
            return .success
        }
        
        
        cmdCenter.nextTrackCommand.addTarget{ [self] _ in
            self.next()
            return .success
        }
        
        cmdCenter.previousTrackCommand.addTarget { [self] _ in
            self.prev()
            return .success
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        setupNotifView()
    }
    
    private func setupArtwork(loader: ImageLoader) {
        var i = 100
        for _ in 0...i {
            print("setup artwork: \(i)")
            if loader.image != nil {
                break
            }
            if i == 30000 {
                break
            }
            i+=100
        }
        
    }
    
    private func setupNotifView() {
        mediaInfo[MPMediaItemPropertyTitle] = song?.title
        mediaInfo[MPMediaItemPropertyArtist] = song?.subtitle
        

        DispatchQueue.main.async {[self] in
            let thumbnail = self.song!.thumbnails!.first!

            let loader = ImageLoader(url: URL(string: thumbnail.url.replacingOccurrences(of: "w\(thumbnail.width)-h\(thumbnail.height)", with: "w720-h720"))!)
            loader.load()
            setupArtwork(loader: loader)
            if loader.image != nil{
                mediaInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 720, height: 720), requestHandler: { (size) -> UIImage in
                    return loader.image!
                })
            }
            
        }
        
        
        mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
    }
    
    private func convertAudio(url: String) {
        if Task.isCancelled {return}
        phase = .converting
        let outputDir = getMusicPath()
        if isMusicExists(outputDir: outputDir) {
            self.playAudio(url: outputDir.absoluteURL, seek: nil)
            return
        }
        let defS = "artist"
        let cmd = "-i \(url) -vn -ab 128k -ar 44100 -movflags +faststart -metadata title=\"\(song!.title)\" -metadata artist=\"\(song!.subtitle ?? defS)\" -y \(outputDir.path())"
        FFmpegKit.executeAsync(cmd) {session in
            guard let session = session else {
                print("invalid session".uppercased())
                return
            }
            
            guard let returnCode = session.getReturnCode() else {
                print("invalid return code".uppercased())
                return
            }
            
            if returnCode.isValueSuccess() {
                DispatchQueue.main.async {
                    self.playAudio(url: outputDir.absoluteURL, seek: nil)
                    self.getCache()
                }
            }
            
        } withLogCallback: { log in
            guard log != nil else {return}
            
        } withStatisticsCallback: { stats in
            guard let stats = stats else {return}
            DispatchQueue.main.async {
                if stats.getSize() > 0 {
                    self.phase = .converting
                }
            }
            
        }
    }
    
    private func onFinish() {
        // finish

        DispatchQueue.main.async {
            switch(self.playbackMode) {
            case .repeatOne:
                self.stop()
                self.repeatOne()
            case .repeatAll:
                self.stop()
                self.next()
            default:
                self.stop()
                self.phase = .finish
            }
            
        }
        
    }
    
    private func setCurrentTime(_ currentTime: CMTime) {
        DispatchQueue.main.async { [self] in
            self.currentTime = currentTime
            self.position = currentTime.seconds
            switch self.player.timeControlStatus {
            case .waitingToPlayAtSpecifiedRate, .paused:
                mediaInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime.seconds
                mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
            case .playing:
                mediaInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime.seconds
                mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
            @unknown default:
                print("failed to notify status")
            }
            
            let thresold = 1.0
            let finished = currentTime.seconds + thresold >= duration.seconds
            
            if finished && playbackMode == .repeatOne {
                repeatOne()
            } else if finished && playbackMode == .repeatAll {
                next()
            }
        }
    }
    
    private func playAudio(url: URL, seek to: Double?) {
        
        if Task.isCancelled{return}
        stop()
            
        initPlayer(url: url)
        
        if to != nil {
            seek(to: to!)
        } else {
            player.play()
        }
        
        DispatchQueue.main.async {
            self.phase = .play
            self.isPlaying = true
        }
    }
    
    private func getMusicPath() -> URL {
        var outputDir: URL {
            musicDir.appendingPathComponent("\(song!.videoId)", conformingTo: .mp3)
        }
        
        return outputDir
    }
    
    private func isMusicExists(outputDir: URL) -> Bool {
        return FileManager.default.fileExists(atPath: outputDir.path())
    }
    
    private func repeatOne() {
        let outputDir = getMusicPath()
        if isMusicExists(outputDir: outputDir) {
            self.playAudio(url: outputDir.absoluteURL, seek: nil)
            return
        } else {
            Task.init {
                await fetchPlayerURL()
            }
            
        }
    }

    
    func next() {
        
        
        DispatchQueue.main.async {[self] in
            var pi = 0
            if index+1 < playlist.count {
                pi = index+1
            }
            self.index = pi
            self.stop()
            self.song = playlist[pi]
            self.setupMediaPlayerNotifView()
            
            let outputDir = getMusicPath()
            if isMusicExists(outputDir: outputDir) {
                self.playAudio(url: outputDir.absoluteURL, seek: nil)
                return
            } else {
                Task.init {
                    await fetchPlayerURL()
                }
                
            }
        }
        
        
    }
    
    func prev() {
        DispatchQueue.main.async {[self] in
            var pi = playlist.count - 1
            if index-1 >= 0 {
                pi = index-1
            }
            self.index = pi
            self.stop()
            self.song = playlist[pi]
            self.setupMediaPlayerNotifView()
            let outputDir = getMusicPath()
            if isMusicExists(outputDir: outputDir) {
                self.playAudio(url: outputDir.absoluteURL, seek: nil)
                return
            } else {
                Task.init {
                    await fetchPlayerURL()
                }
                
            }
        }
    }

    
    func play(song: Song) async {
        
        if song.videoId != self.song?.videoId {
            self.stop()
            self.song = song
            setupMediaPlayerNotifView()
            await fetchPlayerURL()
            return
        }
        self.phase = .play
        self.player.play()
    }
    
    func seek(to pos: Double) {
        let targetTime = CMTime(seconds: pos,
                                preferredTimescale: 600)
        self.player.seek(to: targetTime) {isCompleted in
            self.mediaInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentTime())
            self.mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.mediaInfo
        }
        self.player.play()
        self.phase = .play
        isPlaying = true
    }
    
    func cancel() {
        self.cancellable?.cancel()
    }
    
    func pause() {
        
        self.player.pause()
        DispatchQueue.main.async {[self] in
            self.phase = .pause
            self.isPlaying = false
        }
    }
    
    func stop() {
        player.pause()
        player = AVPlayer()
        cancellable?.cancel()
        setCurrentTime(.zero)
        DispatchQueue.main.async {[self] in
            self.phase = .stop
            self.isPlaying = false
        }
        
    }
    
    func resume() {
        self.player.play()
        DispatchQueue.main.async {
            self.phase = .play
            self.isPlaying = true
        }
    }
    
    func setPlaylist(playlist: [Song], at index: Int) {
        self.playlist = playlist
        self.index = index
        Task.init {
            await self.play(song: playlist[index])
        }
    }
    
    func getCache() {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: URL.init(fileURLWithPath: musicDir.path()), includingPropertiesForKeys: nil, options: [.includesDirectoriesPostOrder, .skipsHiddenFiles]
        ) else {
            self.cacheInfo = "Cache | 0 Kb | 0 Song"
            return
        }
        var folderSize: Int64 = 0
        
        for content in contents {
            do {
                
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: content.path())
                folderSize += fileAttributes[FileAttributeKey.size] as? Int64 ?? 0
            } catch _ {
                continue
            }
        }
        let fileStr = ByteCountFormatter.string(fromByteCount: folderSize, countStyle: ByteCountFormatter.CountStyle.file)
        self.cacheInfo = "Cache | \(fileStr) | \(contents.count) Songs"
    }
    
    func clearCache() {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: URL.init(fileURLWithPath: musicDir.path()), includingPropertiesForKeys: nil, options: [.includesDirectoriesPostOrder, .skipsHiddenFiles]
        ) else {
            return
        }
        
        for content in contents {
            do {
                
                try FileManager.default.removeItem(atPath: content.path())
            } catch _ {
                continue
            }
        }
        self.getCache()
    }
}
