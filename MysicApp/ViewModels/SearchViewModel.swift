//
//  SearchViewModel.swift
//  mysic
//
//  Created by mac on 24/06/23.
//

import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    // Handle API state e.g. EMPTY | SUCCESS | FAILURE and trigger update changes on UI
    // Uses to callback on UI
    @Published var phase = DataFetchPhase<APIResponse>.empty
    
    // Send data to this actor
//    @Published var fetchTaskToken: FetchTaskToken
    
    @Published var data = APIResponse(contents: [], nextAction: QueryParams())
    @Published var history = [Song]()
    
    @Published var isLoadMore = false
    @Published var searchQuery = ""
    
    private let mysicAPI = MysicAPI.shared
    
    // Cache will be expired on 24 Hours or 1 Day
    private let cache = DiskCache<[Song]>(filename: "mysic_search", expirationInterval: 60 * 60 * 24)
    
    private var trimmedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init() {
        Task(priority: .userInitiated) {
            try? await cache.loadFromDisk()
            if let songs = await cache.value(forKey: "mysic") {
                history = songs
            }
        }
    }
    
    func searchSong() async {
        if Task.isCancelled { return }
        
        let searchQuery = trimmedSearchQuery
        phase = .empty
        
        if searchQuery.isEmpty {
            return
        }
        
        do {
            let songs = try await mysicAPI.search(from: .search, params: QueryParams(q: searchQuery))
            if Task.isCancelled { return }
            if searchQuery != trimmedSearchQuery {
                return
            }
            phase = .success(songs)
            data.contents.append(contentsOf: songs.contents)
            data.nextAction = songs.nextAction
            isLoadMore = true
        } catch {
            if Task.isCancelled { return }
            if searchQuery != trimmedSearchQuery {
                return
            }
            phase = .failure(error)
        }
    }
    
    func continueSearchSong() async {
        if Task.isCancelled { return }
        
        phase = .empty
        let searchQuery = trimmedSearchQuery
        if data.nextAction == nil || searchQuery.isEmpty { return }
        
        do {
            let songs = try await mysicAPI.search(from: .search, params: QueryParams(
                next: data.nextAction?.next, params: data.nextAction?.params, ct: data.nextAction?.ct, q: searchQuery))
            if Task.isCancelled {return}
            phase = .success(songs)
            data.contents.append(contentsOf: songs.contents)
            data.nextAction = songs.nextAction
            isLoadMore = true
        } catch {
            if Task.isCancelled { return }
            isLoadMore = false
            phase = .failure(error)
        }
    }
    
    func selectSong(song: Song) {
        history.append(song)
        Task.init {
            await cache.setValue(history, forKey: "mysic")
            try? await cache.saveToDisk()
        }
    }
    
    func resetSearch() {
        self.isLoadMore = false
        self.data = APIResponse(contents: [])
        print(self.searchQuery)
    }
}
