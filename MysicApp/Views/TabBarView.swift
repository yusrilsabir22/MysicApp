//
//  TabBarView.swift
//  MysicApp
//
//  Created by mac on 26/06/23.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var current = 0
    
    @StateObject var globalVM = GlobalViewModel()
    @StateObject var playerVM = PlayerViewModel()
    @StateObject var playerV2VM = PlayerV2Model()
    @StateObject var homeVM = HomeViewModel()
    @StateObject var exploreVM = ExplorerViewModel()
    @StateObject var searchVM = SearchViewModel()
    @StateObject var audioKit = AudioKit()
    
    @Namespace var animation
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            
            TabView(selection: $current) {
                
                HomeTabView()
                    .tag(0)
                    .tabItem {
                        Image(systemName: "music.note.house.fill")
                        Text("Home")
                    }
                ExploreTabView()
                    .tag(1)
                    .tabItem {
                        Image(systemName: "rectangle.grid.2x2.fill")
                        Text("Explore")
                    }
                
                SearchView()
                    .tag(2)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                
                
                
                LibraryTabView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "rectangle.stack.fill")
                        Text("Library")
                    }
                
            }
            
            Miniplayer(animation: animation)
                .opacity(playerV2VM.song != nil ? 1 : 0)
//                .opacity(audioKit.index >= 0 ? 1 : 0)
            
        }
        .environmentObject(globalVM)
        .environmentObject(playerVM)
        .environmentObject(homeVM)
        .environmentObject(exploreVM)
        .environmentObject(searchVM)
        .environmentObject(audioKit)
        .environmentObject(playerV2VM)
        
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
