//
//  HomeTabView.swift
//  MysicApp
//
//  Created by mac on 26/06/23.
//

import SwiftUI

struct HomeTabView: View {
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var isPressed = false
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
    
    var rows = Array(repeating: GridItem(.fixed(80)), count: 4)
    @State var query = ""
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView(showsIndicators: false) {
                Text("Most played today")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                LazyVStack(alignment: .leading, spacing: 40) {
                    
                    ForEach(homeVM.data.datum, id: \.id) { data in
                        
                        if (data.type == "browse") {
                            PlaylistListView(data: data)
                        }
                        
                        if (data.type == "song") {
                            SongListView(data: data)
                        }
                        
                    }
                    if homeVM.isLoadMore {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                    loadMoreTask()
                                }
                            }
                    }
                    
                    
                }
                .padding(.top)
                .padding(.bottom, 80)
                .task(loadTask)
                
            }
            .overlay(overlayView)
            .task(id: homeVM.fetchTaskToken, loadTask)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Home")
        }
    }
        
    @Sendable
    func loadTask() async {
        if homeVM.data.datum.count <= 0 {
            await homeVM.loadDefault()
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch homeVM.phase {
        case .empty:
            if homeVM.data.datum.isEmpty {
                ProgressView()
            }
        case .success(let dt) where dt.datum.isEmpty:
            VStack(spacing: 8) {
                Spacer()
                Text("No data")
                Spacer()
            }
        case .failure(let error) where homeVM.isLoadMore:
            VStack(spacing: 8) {
                Text(error.localizedDescription)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    Task.init {
                        await refreshTask()
                    }
                }) {
                    Text("Try again")
                }
            }
        default: EmptyView()
        }
    }
    
    private var dt: Fetched {
        if case let .success(dt) = homeVM.phase {
            return dt
        } else {
            return Fetched(datum: [])
        }
    }
    
    @Sendable
    private func refreshTask() async {
        DispatchQueue.main.async {
            homeVM.fetchTaskToken = FetchTaskToken(category: homeVM.fetchTaskToken.category, token: Date())
        }
    }
    
    private func loadMoreTask() {
        if homeVM.data.continuation != nil {
            Task.init {
                await homeVM.loadContinuation(params: QueryParams(ct: homeVM.data.continuation!))
            }
        }
        
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
            .environmentObject(HomeViewModel())
    }
}
