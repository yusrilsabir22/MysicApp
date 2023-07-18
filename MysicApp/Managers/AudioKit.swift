//
//  AudioKit.swift
//  MysicApp
//
//  Created by mac on 30/06/23.
//

import Foundation
import MobileVLCKit
import AVFoundation
import MediaPlayer

@MainActor
class AudioKit: ObservableObject {
    @Published var index: Int = -1
    @Published var position: Double = 0
    
    var playlist = [Song]()
    var media = VLCMedia()
    var player = VLCMediaPlayer()
    
    var timer: Timer?
    private let mysicAPI = MysicAPI.shared
    private var mediaInfo = [String : Any]()
    
    
    init() {
        player.libraryInstance.debugLogging = true
    }
    
    deinit {
        self.player.rate = 0
        self.player.stop()
    }
    
    func setPlaylist(playlist: [Song], at index: Int?) {
        self.player.play()
        self.playlist = playlist
        self.index = index ?? 0
        self.play(at: self.index, immediately: true)
        
    }
    
    func play(at index: Int, immediately: Bool = false) {
        if immediately || index != self.index {
            Task.init {
                await self.initPlayer(at: index)
            }
        } else {
            self.player.play()
        }
    }
    
    func pause() {
        self.player.time = VLCTime(int: Int32(self.position))
        self.player.pause()
    }
    
    func resume() {
        self.player.play()
    }
    
    func stop() {
        self.player.stop()
    }
    
    func seek(to value: Int) {
        print("SEEK VALUE: \(value)")
        self.player.time = VLCTime(int: Int32(value))
        self.resume()
    }
    
    func next() {
        let idx = self.getNextIndex()
        Task.init {
            await initPlayer(at: idx)
        }
    }
    
    func getDuration() -> Double {
        return self.player.media != nil ? Double(self.player.media!.length.intValue) : 1.0
    }
    
    func prev() {
        let idx = self.getPrevIndex()
        Task.init {
            await initPlayer(at: idx)
        }
    }
    
    func getCurrentSong(at index: Int = -1) -> Song {
        if self.playlist.isEmpty {
            return GlobalViewModel.mock
        }
        return self.playlist[index >= 0 ? index : self.index]
    }
    
    private func initPlayer(at index: Int) async {
        self.stop()
        DispatchQueue.main.async {
            self.index = index
            self.setupMediaPlayerNotifView()
        }
        
        do {
            let pl = try await mysicAPI.play(from: .play, params: QueryParams(id: self.playlist[index].videoId))
            if Task.isCancelled { return }
            self.media = VLCMedia(url: URL(string: pl.url)!)
            self.player.media = self.media
            self.player.play()
        } catch {
            if Task.isCancelled { return }
            print("FETCH URL: \(error.localizedDescription)")
            return
        }
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
                DispatchQueue.main.async {
                    self.seek(to: Int(event.positionTime*1000))
                    self.resume()
                }                
            }
            return .success
        }
        
//        cmdCenter.changeRepeatModeCommand.addTarget { [unowned self] event in
//            playbackMode = .repeatOne
//            return .success
//        }
//
//        cmdCenter.changeShuffleModeCommand.addTarget { [unowned self] event in
//            playbackMode = .repeatAll
//            return .success
//        }
        
        
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
            if loader.image != nil {
                break
            }
            if i == 5000 {
                break
            }
            i+=10
        }
        
    }
    
    private func setupNotifView() {
        mediaInfo[MPMediaItemPropertyTitle] = self.playlist[self.index].title
        mediaInfo[MPMediaItemPropertyArtist] = self.playlist[self.index].subtitle

        DispatchQueue.main.async {[self] in
            if Task.isCancelled {return}
            let thumbnail = self.playlist[self.index].thumbnails!.first!

            let loader = ImageLoader(url: URL(string: thumbnail.url.replacingOccurrences(of: "w\(thumbnail.width)-h\(thumbnail.height)", with: "w720-h720"))!)
            
            loader.load()
            self.setupArtwork(loader: loader)
            
            self.mediaInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 720, height: 720), requestHandler: { (size) -> UIImage in
                return loader.image!
            })
        }
        
        
        self.mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.mediaInfo
    }
    
    private func getNextIndex() -> Int {
        var idx: Int = 0
        if self.index + 1 < self.playlist.count {
            idx = index + 1
        }
        return idx
    }
    
    private func getPrevIndex() -> Int {
        var idx = self.playlist.count - 1
        if index - 1 >= 0 {
            idx = index - 1
        }
        return idx
    }
    
    func setTimer() {
        self.position = Double(self.player.position)
        self.mediaInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.position
        self.mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        self.mediaInfo[MPMediaItemPropertyPlaybackDuration] = Double(self.player.media.length.intValue/1000)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.mediaInfo
    }
}
