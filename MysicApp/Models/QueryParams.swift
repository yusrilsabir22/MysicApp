//
//  QueryParams.swift
//  mysic
//
//  Created by mac on 23/06/23.
//

import Foundation

struct QueryParams: Codable {
    var next: String?
    var params: String?
    var ct: String?
    var q: String?
    var id: String?
    
    func transformMap() -> Dictionary<String, String> {
        var query: Dictionary<String, String> = [:]
        if next != nil {
            query.merge(dict: ["next": next!])
        }
        
        if params != nil {
            query.merge(dict: ["params": params!])
        }
        
        if ct != nil {
            query.merge(dict: ["ct": ct!])
        }
        
        if q != nil {
            query.merge(dict: ["q": q!])
        }
        
        if id != nil {
            query.merge(dict: ["id": id!])
        }
        
        return query
    }
    
    enum CodingKeys: String, CodingKey {
        case next = "next"
        case params = "params"
        case ct = "ct"
        case q = "q"
        case id = "id"
    }
}
