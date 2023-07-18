//
//  GenreListView.swift
//  MysicApp
//
//  Created by mac on 27/06/23.
//

import SwiftUI

struct GenreListView: View {
    
    var data: DatumContent
    
    var rows = Array(repeating: GridItem(.fixed(70), spacing: 8, alignment: .topLeading), count: 4)
    
    var body: some View {
        VStack {
            
            Text(data.section!)
                .font(.title)
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                LazyHGrid(rows: rows, alignment: .top, spacing: 8) {
                    
                    ForEach(data.dacontents, id: \.id) {item in
                        NavigationLink(
                            destination: DetailGenreView(
                                item: SubGenre(
                                    title: item.title!,
                                    browseID: item.browseID,
                                    params: item.params,
                                    color: item.color!
                                )
                            )
                        ) {
                            
                            GenreTileView(item: item)
                        }
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 0)
                
            }
            
        }
    }
}

//struct GenreListView_Previews: PreviewProvider {
//    static var previews: some View {
//        GenreListView()
//    }
//}
