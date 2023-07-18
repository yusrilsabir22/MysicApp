//
//  Dictionary.swift
//  mysic
//
//  Created by mac on 22/06/23.
//

import Foundation

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
