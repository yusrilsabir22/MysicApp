//
//  Player.swift
//  mysic
//
//  Created by mac on 25/06/23.
//

import Foundation


struct Player: Codable {
    var mimeType: String
    var qualityLabel: String?
    var bitrate, audioBitrate, itag: Int
    var initRange, indexRange: Range
    var lastModified, contentLength, quality, projectionType: String
    var averageBitrate: Int
    var audioQuality, approxDurationMS, audioSampleRate: String
    var audioChannels: Int
    var loudnessDB: Double
    var url: String
    var hasVideo, hasAudio: Bool
    var container, codecs: String
    var videoCodec: String?
    var audioCodec: String
    var isLive, isHLS, isDashMPD: Bool

    enum CodingKeys: String, CodingKey {
        case mimeType, qualityLabel, bitrate, audioBitrate, itag, initRange, indexRange, lastModified, contentLength, quality, projectionType, averageBitrate, audioQuality
        case approxDurationMS = "approxDurationMs"
        case audioSampleRate, audioChannels
        case loudnessDB = "loudnessDb"
        case url, hasVideo, hasAudio, container, codecs, videoCodec, audioCodec, isLive, isHLS, isDashMPD
    }
}

struct Range: Codable {
    var start, end: String
}
