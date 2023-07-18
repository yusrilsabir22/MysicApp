//
//  DetailGenreView.swift
//  MysicApp
//
//  Created by mac on 29/06/23.
//

import SwiftUI

struct DetailGenreView: View {
    
    @State var item: SubGenre
    
    @EnvironmentObject private var explorerVM: ExplorerViewModel
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 40) {
                
                ForEach(data.datum, id: \.id) { it in
                    
                    if (it.type == "browse") {
                        PlaylistListView(data: it)
                    }
                
                    if (it.type == "song") {
                        SongListView(data: it)
                    }
            
                }
            
            }
            .padding(.bottom, 80)
            .overlay(overlayView)
            .task(id: explorerVM.fetchTaskToken, loadTask)
            
        }
    }
    
    var data: Fetched {
        if case let .success(data) = explorerVM.phase{
            return data
        } else {
            return Fetched(datum: [])
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch explorerVM.phase {
        case .empty:
            ProgressView()
        case .success(let data) where data.datum.isEmpty:
            EmptyPlaceholderView(text: "No playlist", image: nil)
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: refreshTask)
        default: EmptyView()
        }
    }
    
    @Sendable
    private func refreshTask() async {
        DispatchQueue.main.async {
            explorerVM.fetchTaskToken = FetchTaskToken(category: explorerVM.fetchTaskToken.category, token: Date())
        }
    }
    
    @Sendable
    private func loadTask() async {
        await explorerVM.loadPlaylist(params: QueryParams(next: item.browseID, params: item.params))
    }
}

struct DetailGenreView_Previews: PreviewProvider {
    static var previews: some View {
        DetailGenreView(
            item: SubGenre(title: "Chill", browseID: "FEmusic_moods_and_genres_category", params: "ggMPOg1uX1JOQWZFeDByc2Jm", color: "#ffffff")
        ).environmentObject(ExplorerViewModel())
    }
}
