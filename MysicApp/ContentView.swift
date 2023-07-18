//
//  ContentView.swift
//  MysicApp
//
//  Created by mac on 26/06/23.
//

import SwiftUI

struct ContentView: View {
    
    // Animation properties
    @State private var expandSheet: Bool = true
    @Namespace private var animation
    
    var body: some View {
        TabView {
        
            SampleTab("Listen Now", "play.circle.fill")
            SampleTab("Browse", "square.grid.2x2.fill")
            SampleTab("Radio", "dot.radiowaves.left.and.right")
            SampleTab("Music", "play.square.stack")
            SampleTab("Search", "magnifyingglass")
        }
        .tint(.red)
        .safeAreaInset(edge: .bottom) {
            CustomBottomSheet()
        }
        .overlay {
            if expandSheet {
                ExpandedBottomSheet(expandSheet: $expandSheet, animation: animation)
                // Transition for more fluent Animation
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
            }
        }
    }
    
    @ViewBuilder
    func CustomBottomSheet() -> some View {
        // Animating Sheet Background (To Look Like It's Expanding From the bottom)
        ZStack {
            if expandSheet {
                Rectangle()
                    .fill(.clear)
            } else {
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .overlay {
                        // Music info
                        MusicInfo(expandSheet: $expandSheet, animation: animation)
                    }
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
            }
        }
        .frame(height: 70)
        //Separator line
        .overlay(alignment: .bottom, content: {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 1)
                .offset(y: -5)
        })
        // 49: Default tab bar height
        .offset(y: -49)
    }
    
    
    @ViewBuilder
    func SampleTab(_ title: String, _ icon: String) -> some View  {
        Text(title)
            .tabItem {
                Image(systemName: icon)
                Text(title)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.ultraThickMaterial, for: .tabBar)
            // hide tab bar when expanded
            .toolbar(expandSheet ? .hidden : .visible, for: .tabBar)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}


// Reusable view
struct MusicInfo: View {
    
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    var body: some View {
        
        HStack(spacing: 0) {
            // Adding Matched Geometry Effect (Hero Animation)
            ZStack {
                if !expandSheet {
                    GeometryReader {
                        
                        let size = $0.size
                        
                        Image("pic")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: expandSheet ? 15 : 5, style: .continuous))
                        
                    }
                    .matchedGeometryEffect(id: "ARTWORK", in: animation)
                }
            }
            .frame(width: 45, height: 45)
            
            
            Text("Look What You Made Me Do")
                .fontWeight(.bold)
                .lineLimit(1)
                .padding(.horizontal, 15)
            
            Spacer(minLength: 0)
            
            Button(action: {}) {
                Image(systemName: "pause.fill")
                    .font(.title2)
            }
            
            Button(action: {}) {
                Image(systemName: "forward.fill")
                    .font(.title2)
            }
            .padding(.leading, 25)
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .padding(.bottom, 5)
        .frame(height: 70)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                expandSheet = true
            }
        }
        
    }
    
}
