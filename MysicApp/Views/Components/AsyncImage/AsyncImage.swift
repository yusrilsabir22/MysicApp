//
//  AsyncImage.swift
//  mysic
//
//  Created by mac on 20/06/23.
//

import Foundation
import SwiftUI


// example use

/**
 AsyncImage(
     url: URL(string: imgUrl!)!,
     placeholder: {
         Image("pic")
             .resizable()
             .aspectRatio(contentMode: .fill)
             .frame(
                 width: UIScreen.main.bounds.height * 0.15,
                 height: UIScreen.main.bounds.height * 0.15
             )
         
     },
     image: { Image(uiImage: $0).resizable() }
 )
 .aspectRatio(contentMode: .fit)
 .frame(
     width: UIScreen.main.bounds.height * 0.15,
     height: UIScreen.main.bounds.height * 0.15
 )
 */


struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (UIImage) -> Image
    
    var di = Environment(\.imageCache)
    
    init(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
    }
    
    private var content: some View {
        Group {
            if loader.image != nil {
                image(loader.image!)
            } else {
                placeholder
            }
        }
    }
}
