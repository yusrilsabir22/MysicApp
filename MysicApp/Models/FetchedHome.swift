//
//  FetchedHome.swift
//  mysic
//
//  Created by mac on 20/06/23.
//

import Foundation
import SwiftUI


struct Fetched: Codable, Identifiable {
    var id = NSUUID()
    var datum: [DatumContent]
    var continuation: String?
    enum CodingKeys: String, CodingKey{
        case datum = "data"
        case continuation = "continuation"
    }
}

struct DatumContent: Codable, Identifiable {
    var id = UUID()
    var section: String?
    var type: String
    var dacontents: [DatumContentItem]
    enum CodingKeys: String, CodingKey{
        case section = "section"
        case type = "type"
        case dacontents = "contents"
    }
}


struct DatumContentItem: Codable, Identifiable {
    var id = UUID()
    var videoID: String?
    var title: String?
    var subtitle: String?
    var thumbnails: [Thumbnail]?
    var browseID: String?
    var params: String?
    var color: String?
    var browseId: String?
    var duration: String?
    var totalDuration: Int?
    
    enum CodingKeys: String, CodingKey{
        case videoID = "videoId"
        case title = "title"
        case subtitle = "subtitle"
        case thumbnails = "thumbnails"
        case browseID = "browseId"
        case params = "params"
        case color = "color"
        case duration = "duration"
        case totalDuration = "totalDuration"
    }
}


struct Thumbnail: Codable, Identifiable {
    var id = UUID()
    var url: String
    var width: Int
    var height: Int
    
    enum CodingKeys: String, CodingKey{
        case url = "url"
        case width = "width"
        case height = "height"
    }
}
