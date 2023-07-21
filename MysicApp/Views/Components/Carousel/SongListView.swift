//
//  SongListView.swift
//  MysicApp
//
//  Created by mac on 27/06/23.
//

import SwiftUI

struct SongListView: View {
    @EnvironmentObject var globalVM: GlobalViewModel
    @EnvironmentObject var playerVM: PlayerV2Model
    @EnvironmentObject var audioKit: AudioKit
    
    var data: DatumContent
    
    var rows = Array(repeating: GridItem(.fixed(50)), count: 4)
    
    var body: some View {
        
        VStack {
            
            Text(data.section!)
                .font(.title)
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                LazyHGrid(rows: rows, spacing: 0) {
                    
                    ForEach(0..<data.dacontents.filter({ item in
                        item.videoID != nil
                    }).count) {index in
                        if data.dacontents[index].videoID != nil {
                            Button(action: {
                                playerVM.setPlaylist(playlist: data.dacontents.filter({ item in
                                    item.videoID != nil
                                }).map{
                                    Song(
                                        title: $0.title!,
                                        videoId: $0.videoID!,
                                        subtitle: $0.subtitle,
                                        duration: $0.duration,
                                        totalDuration: $0.totalDuration,
                                        thumbnails: $0.thumbnails
                                    )
                                }, at: index)
                            }) {
                                SongTileView(item: Song(
                                    title: data.dacontents[index].title!,
                                    videoId: data.dacontents[index].videoID!,
                                    subtitle: data.dacontents[index].subtitle,
                                    duration: data.dacontents[index].duration,
                                    totalDuration: data.dacontents[index].totalDuration,
                                    thumbnails: data.dacontents[index].thumbnails
                                    
                                ))
                                .frame(width: UIScreen.main.bounds.width*0.7)
                            }
                        }
                        
                    }
                    
                }
                
            }
            .padding(.all, 0)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
            
        }
    }
}
