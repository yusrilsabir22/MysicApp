//
//  SearchViewModel.swift
//  mysic
//
//  Created by mac on 23/06/23.
//

import Foundation

enum DataFetchPhase<T> {
    
    case empty
    case success(T)
    case failure(Error)
}

struct FetchTaskToken: Equatable {
    var category: Category
    var token: Date
}


@MainActor
class ExplorerViewModel: ObservableObject {
    // Handle API state e.g. EMPTY | SUCCESS | FAILURE and trigger update changes on UI
    @Published var phase = DataFetchPhase<Fetched>.empty
    @Published var phaseNext = DataFetchPhase<DatumContent>.empty
    @Published var history = [String]()
    private let historyMaxLimit = 10
    
    // Send data to main actor
    @Published var fetchTaskToken: FetchTaskToken
    
    @Published var searchQuery = ""
    @Published var data = Fetched(datum: [])
    
    private let mysicAPI = MysicAPI.shared
    
    // Cache will be expired on 24 Hours or 1 Day
    private let cache = DiskCache<Fetched>(filename: "mysic_explorer", expirationInterval: 60 * 60 * 24)
    
    private let cacheHistory = DiskCache<[String]>(filename: "mysic_search_history", expirationInterval: 60 * 60 * 24)
    
    private var trimmedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init(data: Fetched? = nil, selectedCategory: Category = .explorer) {
        if let data = data {
            self.phase = .success(data)
        } else {
            self.phase = .empty
        }
        self.fetchTaskToken = FetchTaskToken(category: selectedCategory, token: Date())
        
        // Load
        Task(priority: .userInitiated) {
            try? await cache.loadFromDisk()
            try? await cacheHistory.loadFromDisk()
            if let h = await cacheHistory.value(forKey: "history") {
                history = h
            }
        }
    }
    
    func loadDefault() async {
        if Task.isCancelled { return }
        
        let category = fetchTaskToken.category

        if let explorer = await cache.value(forKey: category.rawValue) {
            phase = .success(explorer)
            data = explorer
            return
        }
        
        phase = .empty
        do {
            let data = try await mysicAPI.fetch(from: .explorer, params: nil)
            if Task.isCancelled { return }
            await cache.setValue(data, forKey: category.rawValue)
            try? await cache.saveToDisk()
            phase = .success(data)
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
    
    func loadPlaylist(params: QueryParams) async {
        if Task.isCancelled { return }
        _ = fetchTaskToken.category
        if let next = await cache.value(forKey: getKey(for: params)) {
            phase = .success(next)
            return
        }
        
        phase = .empty
        do {
            let result = try await mysicAPI.fetch(from: .explorer, params: params)
            if Task.isCancelled { return }
            phase = .success(result)
            await cache.setValue(result, forKey: getKey(for: params))
            try? await cache.saveToDisk()
            
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
    
    func loadSearch(query: String) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let data = try await mysicAPI.fetch(from: .search, params: QueryParams(q: query))
            if Task.isCancelled { return }
            phase = .success(data)
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
    
    func addHistory(_ text: String) {
        if let index = history.firstIndex(where: { text.lowercased() == $0.lowercased() }) {
            history.remove(at: index)
        }
        
        history.insert(text, at: 0)
        historiesUpdated()
    }
    
    func removeHistory(_ text: String) {
        guard let index = history.firstIndex(where: { text.lowercased() == $0.lowercased() }) else {
            return
        }
        history.remove(at: index)
        historiesUpdated()
    }
    
    func removeAllHistory() {
        history.removeAll()
        historiesUpdated()
    }
    
    private func historiesUpdated() {
        let history = self.history
        Task {
            await cacheHistory.setValue(history, forKey: "history")
            try? await cacheHistory.saveToDisk()
        }
    }
    
    private func getKey(for query: QueryParams) -> String {
        return query.transformMap().values.joined(separator: ".")
    }
}
