//
//  PlaylistTileView.swift
//  MysicApp
//
//  Created by mac on 27/06/23.
//

import SwiftUI

struct PlaylistTileView: View {
    var item: SubPlaylist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AsyncImage(
                url: item.imgURL!,
                placeholder: {
                    Image("pic")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: UIScreen.main.bounds.height * 0.15,
                            height: UIScreen.main.bounds.height * 0.15
                        )
                },
                image: {Image(uiImage: $0).resizable()}
            )
            .aspectRatio(contentMode: .fill)
            .frame(
                width: UIScreen.main.bounds.height * 0.15,
                height: UIScreen.main.bounds.height * 0.15
            )
            
            
            Text(item.title)
                .font(.headline)
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .lineLimit(1)
            
            if item.subtitle != nil{
                Text(item.subtitle!)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
        }
        .frame(width: UIScreen.main.bounds.height * 0.15)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.25)
    }
}

struct PlaylistTileView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistTileView(
            item: SubPlaylist(
                title: "Playlist 1", browseID: "1", thumbnails: [
                    Thumbnail(
                        url: "https://lh3.googleusercontent.com/-DUA7w57wuDybKVO84upkSsm3YipitP0RSnKvEX_AO9y6nB7NXydr6mL6p1W6nL1Ifutm_VfMU96G7FW=w544-h544-l90-rj", width: 720, height: 720
                    )
                ]
            )
        )
    }
}
