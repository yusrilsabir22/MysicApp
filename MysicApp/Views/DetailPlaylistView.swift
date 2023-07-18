//
//  DetailPlaylistView.swift
//  MysicApp
//
//  Created by mac on 28/06/23.
//

import SwiftUI

struct DetailPlaylistView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    @EnvironmentObject var globalVM: GlobalViewModel
    @EnvironmentObject var audioKit: AudioKit
    @State var item: SubPlaylist
    @State private var contents = DatumContent(type: "", dacontents: [])
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(
                    url: item.imgURL!,
                        placeholder: {
                            Image("pic")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(13)
                                .frame(width: UIScreen.main.bounds.height * 0.3, height: UIScreen.main.bounds.height * 0.3)
                            
                        },
                        image: { Image(uiImage: $0).resizable() }
                     )
                .aspectRatio(contentMode: .fill)
                .cornerRadius(13)
                .frame(width: UIScreen.main.bounds.height * 0.3, height: UIScreen.main.bounds.height * 0.3)
                
                Text(item.title)
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                
                
                HStack(alignment: .center, spacing: 15) {
                    
                    Button(action: {}) {
                        Image(systemName: "shuffle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.primary)
                    }
                    .frame(width: UIScreen.main.bounds.width / 2)
                    
                    
                    
                    Button(action: {}) {
                        Image(systemName: "play.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.primary)
                    }
                    .frame(width: UIScreen.main.bounds.width / 2)
                    
                }
                .padding(.vertical, 20)

                Spacer(minLength: 0)
                
                VStack(spacing: 0) {
                    ForEach(0..<self.contents.dacontents.count, id: \.self) {index in
                        Button(action:{
                            playerVM.setPlaylist(playlist: self.contents.dacontents.map{
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
                            let it = self.contents.dacontents[index]
                            SongTileView(
                                item: Song(
                                    title: it.title!,
                                    videoId: it.videoID!,
                                    subtitle: it.subtitle,
                                    duration: it.duration,
                                    thumbnails: it.thumbnails != nil ? it.thumbnails : [
                                        Thumbnail(
                                            url: item.imgURL!.path,
                                            width: 720,
                                            height: 720
                                        )
                                    ]
                                )
                            )
                        }
                    }
                }
                
            }
            .padding(.bottom, 70)
            .onAppear {
                Task.init {
                    let uri = "http://192.168.18.10:3000/v2";
                    var components = URLComponents(string: "\(uri)/browse")
                    var params: Dictionary<String, String> = ["next": item.browseID]
                    
                    if item.params != nil {
                        params.merge(dict: ["params": item.params!])
                    }
                    
                    components?.queryItems = params.map{k,v in URLQueryItem(name: k, value: v)}
                    
                    do {
                        let (datum, _) = try await URLSession.shared.data(from: URL(string: components!.string!)!)
                        // decode response
                        if let decodeResponse = try? JSONDecoder().decode(DatumContent.self, from: datum) {
                            contents = decodeResponse
                            
                        }
                    } catch {
                        print("Error")
                    }
                }
            }
           
        }
        
    }
}

struct DetailPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        DetailPlaylistView(
            item: SubPlaylist(
            title: "test",
            browseID: "VLRDCLAK5uy_nMln2JPa-4fhqwquE3dRinwNr6IkN2-7k",
            thumbnails: [
                Thumbnail(url: "https://lh3.googleusercontent.com/-DUA7w57wuDybKVO84upkSsm3YipitP0RSnKvEX_AO9y6nB7NXydr6mL6p1W6nL1Ifutm_VfMU96G7FW=w544-h544-l90-rj", width: 300, height: 300)
            ]
        ))
        .environmentObject(GlobalViewModel())
        .environmentObject(PlayerViewModel())
    }
}
