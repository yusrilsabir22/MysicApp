//
//  SubGenre.swift
//  mysic
//
//  Created by mac on 23/06/23.
//

import Foundation

struct SubGenre: Identifiable, Hashable {
    let id = NSUUID()
    var title: String
    var browseID: String?
    var params: String?
    var color: String
}
