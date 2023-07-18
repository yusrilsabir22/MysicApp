//
//  SongTileView.swift
//  MysicApp
//
//  Created by mac on 27/06/23.
//

import SwiftUI

struct SongTileView: View {
    @EnvironmentObject var globalVM: GlobalViewModel
    var item: Song
    
    var body: some View {
        HStack {
            
            if item.imgURL != nil {
                AsyncImage(
                    url: item.imgURL!,
                    placeholder: { Image("pic").resizable().aspectRatio(contentMode: .fit).frame(width: 45, height: 45) },
                    image: { Image(uiImage: $0).resizable()}
                 )
                .frame(width: 45, height: 45)
            }
            
            VStack(alignment: .leading) {
                
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                if item.subtitle != nil {
                    Text(item.subtitle!)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
            }
            
            Spacer(minLength: 0)
            
            if item.duration != nil {
                Text(item.duration ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        }
        .padding()
    }
}

struct SongTileView_Previews: PreviewProvider {
    static var previews: some View {
        SongTileView(item: GlobalViewModel.mock)
    }
}
