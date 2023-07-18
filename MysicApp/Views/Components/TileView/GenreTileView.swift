//
//  GenreTileView.swift
//  MysicApp
//
//  Created by mac on 27/06/23.
//

import SwiftUI

struct GenreTileView: View {
    var item: DatumContentItem
    
    var body: some View {
        VStack {
            VStack {
                
                Text(item.title ?? "")
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(width: 130)
                
            }
            .frame(width: 180, height: 70)
            .background(BlurView())
            .overlay(
                Rectangle()
                    .frame(width: 15, height: nil, alignment: .leading)
                    .foregroundColor(Color(item.color ?? "#000000")),
                alignment: .leading
            )
        }
    }
}

struct GenreTileView_Previews: PreviewProvider {
    static var previews: some View {
        GenreTileView(item: DatumContentItem(
            title: "Indonesia",
            browseID: "1",
            color: "#FFF000"
        ))
    }
}
