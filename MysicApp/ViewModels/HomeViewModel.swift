//
//  HomeViewModel.swift
//  mysic
//
//  Created by mac on 23/06/23.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    // Handle API state e.g. EMPTY | SUCCESS | FAILURE and trigger update changes on UI
    // Uses to callback on UI
    @Published var phase = DataFetchPhase<Fetched>.empty
    
    // Send data to this actor
    @Published var fetchTaskToken: FetchTaskToken
    
    @Published var data = Fetched(datum: [])
    
    @Published var isLoadMore = true
    
    private let mysicAPI = MysicAPI.shared
    
    // Cache will be expired on 24 Hours or 1 Day
    private let cache = DiskCache<Fetched>(filename: "mysic_explorer", expirationInterval: 60 * 60 * 24)
    
    init(data: Fetched? = nil, selectedCategory: Category = .home) {
        
        if let data = data {
            self.phase = .success(data)
        } else {
            self.phase = .empty
        }
        self.fetchTaskToken = FetchTaskToken(category: selectedCategory, token: Date())
        
        Task(priority: .userInitiated) {
            try? await cache.loadFromDisk()
        }
    }
    
    func loadDefault() async {
        if Task.isCancelled { return }
        
        let category = fetchTaskToken.category
        if let home = await cache.value(forKey: category.rawValue) {
            phase = .success(home)
            data = home
            return
        }
        
        phase = .empty
        do {
            let home = try await mysicAPI.fetch(from: .home, params: nil)
            if Task.isCancelled { return }
            await cache.setValue(home, forKey: category.rawValue)
            try? await cache.saveToDisk()
            DispatchQueue.main.async {
                self.phase = .success(home)
                self.data = home
            }
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
    
    func loadContinuation(params: QueryParams) async {

        if Task.isCancelled { return }
        phase = .empty
        do {
            let result = try await mysicAPI.fetch(from: .browse, params: params)
            if Task.isCancelled { return }
            phase = .success(result)
            data.continuation = result.continuation
            data.datum.append(contentsOf: result.datum)
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
            isLoadMore = false
            phase = .failure(error)
        }
    }
}
