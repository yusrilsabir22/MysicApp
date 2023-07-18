//
//  SearchView.swift
//  MysicApp
//
//  Created by mac on 29/06/23.
//

import SwiftUI

struct SearchView: View {
    enum FocusField: Hashable {
        case field
      }
    
    @EnvironmentObject var searchVM: SearchViewModel
    private var testIMG = "https://lh3.googleusercontent.com/-DUA7w57wuDybKVO84upkSsm3YipitP0RSnKvEX_AO9y6nB7NXydr6mL6p1W6nL1Ifutm_VfMU96G7FW=w544-h544-l90-rj"
    private var width = UIScreen.main.bounds.size.width
    private var height = UIScreen.main.bounds.size.height
    @FocusState private var focusedField: Bool
    @State private var searchText = ""
    @State private var f: Bool = true
    
    var body: some View {
        NavigationStack {
            TextField("Search", text: $searchVM.searchQuery)
                .padding(.all, 8)
                .padding(.leading)
                .cornerRadius(8)
            
            ScrollView {
                VStack(alignment: .leading) {
                    
                    
                    
                    if searchVM.data.contents.isEmpty {
                        Text("Find your favorite songs")
                            .foregroundColor(.secondary)
                            .font(.body)
                            .padding(.leading)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Search")
                
                
            }
            .padding()
        }
                
    }
    
    
    private func search() {
        Task {
            await searchVM.searchSong()
        }
    }
    
    private func loadMoreTask() {
        Task.init {
            await searchVM.continueSearchSong()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(SearchViewModel())
    }
}
