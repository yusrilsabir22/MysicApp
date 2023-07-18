//
//  ExpandedBottomSheet.swift
//  MysicApp
//
//  Created by mac on 03/07/23.
//

import SwiftUI

struct ExpandedBottomSheet: View {
    
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    
    // View properties
    @State private var animationContent: Bool = true
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
                RoundedRectangle(cornerRadius: animationContent ? deviceCornerRadius : 0, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: animationContent ? deviceCornerRadius : 0, style: .continuous)
                            .fill(Color("BG"))
                            .opacity(animationContent ? 1 : 0)
                    }
                    .overlay(alignment: .top) {
                        MusicInfo(expandSheet: $expandSheet, animation: animation)
                            .allowsHitTesting(false)
                            .opacity(animationContent ? 0 : 1)
                    }
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
                
                VStack(spacing: 15) {
                    // Grab indicator
                    Capsule()
                        .fill(.gray)
                        .frame(width: 40, height: 5)
                        .opacity(animationContent ? 1 : 0)
                        .offset(y: animationContent ? 0 : size.height)
                    
                    // Artwork Hero View
                    GeometryReader {
                        let size = $0.size
                        
                        Image("pic")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: animationContent ? 15 : 5, style: .continuous))
                        
                    }
                    .matchedGeometryEffect(id: "ARTWORK", in: animation)
                    // For square Artwork image
                    .frame(height: size.width - 50)
                    // For smaller device padding will be 10 and the larger device padding 30
                    .padding(.vertical, size.height < 700 ? 10 : 30)
                    
                    // Player view
                    PlayerView(size)
                    // moving it from bottom
                        .offset(y: animationContent ? 0 : size.height)
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
                
            }
            .contentShape(Rectangle())
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged({value in
                        let translataionY = value.translation.height
                        offsetY = (translataionY > 0 ? translataionY : 0)
                    })
                    .onEnded({value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if offsetY > size.height * 0.4 {
                                expandSheet = false
                                animationContent = false
                            } else {
                                offsetY = .zero
                            }
                        }
                    })
            )
            .ignoresSafeArea(.container, edges: .all)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animationContent = true
            }
        }
    }
    
    @ViewBuilder
    func PlayerView(_ mainSize: CGSize) -> some View {
        GeometryReader {
            let size = $0.size
            
            // Dynamic spacing using available height
            let spacing = size.height * 0.04
            
            VStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    HStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Look What You Made Me Do")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Taylor Swift")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding(12)
                                .background {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .light)
                                }
                        }
                            
                    }
                    
                    // Timing indicator
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .light)
                        .frame(height: 5)
                        .padding(.top, spacing)
                    
                    // Timing label view
                    HStack {
                        Text("00:00")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer(minLength: 0)
                        
                        Text("03:33")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
                .frame(height: size.height/2.5, alignment: .top)
                
                // Playback Controls
                HStack(spacing: size.width * 0.18) {
                    Button {
                        
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(size.height < 300 ? .title3 : .title)
                    }

                }
                .foregroundColor(.white)
                .frame(maxHeight: .infinity)
                
                // Other controls
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.gray)
                        
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .light)
                            .frame(height: 5)
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.gray)
                    }
                    
                    HStack(alignment: .top, spacing: size.width * 0.18) {
                        Button {
                            
                        } label: {
                            Image(systemName: "quote.bubble")
                                .font(.title2)
                        }
                        
                        Spacer(minLength: 0)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                        }
                    }
                    .foregroundColor(.white)
                    .blendMode(.overlay)
                    .padding(.top, spacing)
                }
                .frame(height: size.height/3, alignment: .bottom)
            }
        }
    }
}

struct ExpandedBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}


extension View {
    var deviceCornerRadius: CGFloat {
        let key = "_displayCornerRadius"
        if let screen = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen {
            if let cornerRadius = screen.value(forKey: key) as? CGFloat {
                return cornerRadius
            }
            
            return 0
        }
        
        return 0
    }
}
