//
//  Search.swift
//  mysic
//
//  Created by mac on 20/06/23.
//

import SwiftUI

struct ExploreTabView: View {
    
    @EnvironmentObject var globalVM: GlobalViewModel
    @EnvironmentObject var explorerVM: ExplorerViewModel
    @State var isSearchSubmitted = false
    
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
    
    var body: some View {

        NavigationStack {
            
            BaseContainer {
                ScrollView {
                    
                    VStack {
                        
                        VStack(spacing: 40) {
                            ForEach(explorerVM.data.datum, id: \.id) { dt in
                                
                                // Type Browse
                                if(dt.type == "browse") {
                                    PlaylistListView(data: dt)
                                }
                                
                                // Type Song
                                if(dt.type == "song") {
                                    SongListView(data: dt)
                                }
                                
                                // Type Mood & Genre
                                
                                if(dt.type == "genre") {
                                    
                                    GenreListView(data: dt)
                                }
                                
                                
                            }
                            
                        }
                        .padding(.top)
                        .padding(.bottom, 80)
                        .task(id: explorerVM.fetchTaskToken, loadTask)
                        
                    }
                    
                }
            }
            .navigationTitle("Explore")
            
        }
            
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch explorerVM.phase {
        case .empty:
            if !explorerVM.searchQuery.isEmpty {
                ProgressView()
            } else if !explorerVM.history.isEmpty {
                EmptyPlaceholderView(text: "Type your query to search songs", image: Image(systemName: "magnifyingglass"))
            } else {
                EmptyPlaceholderView(text: "Type your query to search songs", image: Image(systemName: "magnifyingglass"))
            }
        default: EmptyView()
        }
    
    }
    
    @ViewBuilder
    private var suggestionView: some View {
        let _ = print("suggestionView: \(explorerVM.phase)")
        if explorerVM.history.isEmpty {
            Text("type your favorite song")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        ForEach(explorerVM.history, id: \.self) { text in
            HStack {
                
                Button {
                    explorerVM.searchQuery = text
                } label: {
                    Text(text)
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "xmark")
                    .onTapGesture {
                        explorerVM.removeHistory(text)
                    }
            }
            
        }
        
    }
    
    private func search() {
        let searchQuery = explorerVM.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchQuery.isEmpty {
            explorerVM.addHistory(searchQuery)
        }
        isSearchSubmitted = true
    }
    
    @Sendable
    private func loadTask() async {
        if explorerVM.data.datum.isEmpty {
            await explorerVM.loadDefault()
        }
    }
}

struct ExploreTabView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ExploreTabView()
            .environmentObject(GlobalViewModel())
            .environmentObject(ExplorerViewModel())
    }
}
