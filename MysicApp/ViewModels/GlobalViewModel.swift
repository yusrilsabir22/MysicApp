//
//  GlobalViewMode.swift
//  MysicApp
//
//  Created by mac on 26/06/23.
//

import Foundation
import Combine
import SwiftUI


@MainActor class GlobalViewModel: ObservableObject {
    static var mock = Song(
        title: "Poker Face", videoId: "mock", subtitle: "Lady Gaga",
        thumbnails: [
            Thumbnail(url: "https://lh3.googleusercontent.com/-DUA7w57wuDybKVO84upkSsm3YipitP0RSnKvEX_AO9y6nB7NXydr6mL6p1W6nL1Ifutm_VfMU96G7FW=w544-h544-l90-rj", width: 720, height: 720)
        ]
    )
    
    @Published var expandSearch = false
    @Published var selectedSong: Song = mock
    @Published var expand = true
    
    @Published var imageData: Data?
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()
    
    
    func loadImage(from url: URL?) {
        isLoading = true
        guard let url = url else {
            isLoading = false
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.imageData = $0
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    
    func selectSong(song: Song) {
        withAnimation(.spring()){
            selectedSong = song
            expand = true
        }
    }
    
    func openSearch() {
        withAnimation(.spring()){
            expandSearch = true
        }
    }
    
    func closeSearch() {
        withAnimation(.spring()){
            expandSearch = false
        }
    }
}
