//
//  PlaylistListView.swift
//  MysicApp
//
//  Created by mac on 26/06/23.
//

import SwiftUI

struct PlaylistListView: View {
    
    var data: DatumContent
    
    var body: some View {
        
        VStack {
            Text(data.section!)
                .font(.title)
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    ForEach(data.dacontents, id: \.id) {item in
                        if item.browseID != nil {
                            NavigationLink(
                                destination: DetailPlaylistView(
                                    item: SubPlaylist(
                                        title: item.title!,
                                        browseID: item.browseID!,
                                        thumbnails: item.thumbnails,
                                        subtitle: item.subtitle,
                                        params: item.params
                                    )
                                )
                            ) {
                                
                                PlaylistTileView(item: SubPlaylist(
                                    title: item.title!,
                                    browseID: item.browseID!,
                                    thumbnails: item.thumbnails,
                                    subtitle: item.subtitle,
                                    params: item.params
                                ))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
            }
            
        }
    }
}
