//
//  Binding.swift
//  mysic
//
//  Created by mac on 21/06/23.
//

import SwiftUI


extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
