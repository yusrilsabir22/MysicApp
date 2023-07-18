//
//  EnvironmentValues+ImageCache.swift
//  mysic
//
//  Created by mac on 20/06/23.
//

import SwiftUI


struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
