//
//  Category.swift
//  mysic
//
//  Created by mac on 23/06/23.
//

import Foundation


enum Category: String, CaseIterable {
    case search
    case home
    case explorer
    case browse
    case play
    case playInfo="play-info"
    
    var text: String {
        return rawValue.lowercased()
    }
}

extension Category: Identifiable {
    var id: Self { self }
}
