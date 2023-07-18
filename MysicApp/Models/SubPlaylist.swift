//
//  SubPlaylist.swift
//  mysic
//
//  Created by mac on 21/06/23.
//

import Foundation


struct SubPlaylist{
    
    let id = NSUUID()
    let title: String
    let browseID: String
    let thumbnails: [Thumbnail]?
    var subtitle: String?
    var params: String?
    
    var imgURL: URL? {
        if self.thumbnails != nil {
            return URL(string: self.thumbnails!.last!.url)
        } else {
            // we can set default image if there is no given image
            return nil
        }
    }
}
