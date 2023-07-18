//
//  Song.swift
//  mysic
//
//  Created by mac on 24/06/23.
//

import Foundation


struct APIResponse: Codable {
    var id = NSUUID()
    var contents: [Song]
    var nextAction: QueryParams?
    
    enum CodingKeys: String, CodingKey {
        case contents = "contents"
        case nextAction = "nextAction"
    }
}

struct Song: Codable {
    var id = NSUUID()
    var title: String
    var videoId: String
    var subtitle: String?
    var duration: String?
    var totalDuration: Int?
    var thumbnails: [Thumbnail]?
    var imgURL: URL? {
        if self.thumbnails != nil {
            return URL(string: self.thumbnails!.last!.url)
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case videoId = "videoId"
        case subtitle = "subtitle"
        case thumbnails = "thumbnails"
        case duration = "duration"
        case totalDuration = "totalDuration"
    }
}
