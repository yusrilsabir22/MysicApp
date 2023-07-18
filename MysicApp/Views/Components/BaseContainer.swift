//
//  BaseContainer.swift
//  MysicApp
//
//  Created by mac on 27/06/23.
//

import SwiftUI

struct BaseContainer<Content: View>: View {
    private let content: Content
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        ZStack(alignment: .top) {
//            CustomAppBar()
//                .zIndex(1)
            content
        }
    }
}
