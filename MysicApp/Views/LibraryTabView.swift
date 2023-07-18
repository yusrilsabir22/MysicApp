//
//  LibraryTabView.swift
//  MysicApp
//
//  Created by mac on 26/06/23.
//

import SwiftUI

struct LibraryTabView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
    
    var body: some View {
        NavigationStack {
            BaseContainer {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20){
                        Spacer(minLength: 0)
                        
                        // List grid saved playlist
//                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 0)], spacing: 5) {
//
//                            Section {
//
//                                ForEach(1...5, id: \.self) {i in
//                                    LibraryTile()
//                                }
//
//                            }
//
//                        }
//                        .padding(.bottom, 70)
                        
                        // Storage
                        VStack(spacing: 10) {
                            Text("Storage")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(.primary)
                            
                            Text(playerVM.cacheInfo)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            HStack(alignment: .center) {
                                Button(action: {
                                    playerVM.clearCache()
                                }) {
                                    Text("Clear cache")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        
                                }
                                .padding(.all, 15)
                                .background(BlurView())
                                .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        
                        
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .padding(.top)
                    .padding(.bottom, 80)
                    
                }
            }
            .navigationTitle("Library")
        }
    }
}

struct LibraryTabView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryTabView()
            .environmentObject(PlayerViewModel())
    }
}
