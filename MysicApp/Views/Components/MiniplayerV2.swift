//
//  MiniplayerV2.swift
//  MysicApp
//
//  Created by mac on 01/07/23.
//

import SwiftUI
import Combine

struct MiniplayerV2: View {
    @EnvironmentObject var globalVM: GlobalViewModel
    @EnvironmentObject var audioKit: AudioKit
    
    var animation: Namespace.ID
    
    @State var position = 0.0
    @State private var timer: Timer?
    
    // Gesture offset
    @State var offset: CGFloat = 0
    
    
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets
    var height = UIScreen.main.bounds.height / 3 + 25
    
    var body: some View {
        VStack {
            
            Capsule()
                .fill(.gray)
                .frame(width: globalVM.expand ? 60 : 4, height: globalVM.expand ? 4 : 0)
                .opacity(globalVM.expand ? 1 : 0)
                .padding(.top, globalVM.expand ? safeArea?.top : 0)
                .padding(.vertical, globalVM.expand ? 30 : 0)
            
            
            HStack(alignment: .center) {
                
                // Centering image
                if globalVM.expand {
                    Spacer(minLength: 0)
                    Spacer(minLength: 0)
                }
                
                // Image player
                Group {
                    
                    if let data = globalVM.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                    } else if globalVM.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "photo")
                    }
                }
                .frame(
                    width: globalVM.expand ? height : 55,
                    height: globalVM.expand ? height+30 : 55
                )
                .onReceive(audioKit.$index) { newVal in
                    if newVal >= 0 {
                        globalVM.loadImage(from: audioKit.getCurrentSong(at: newVal).imgURL)
                    }
                }
                
                if !globalVM.expand {
                    
                    VStack(alignment: .leading) {
                        
                        Text(audioKit.getCurrentSong().title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                            .matchedGeometryEffect(id: "Label", in: animation)
                        
                        if audioKit.getCurrentSong().subtitle != nil {
                            Text(audioKit.getCurrentSong().subtitle!)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .matchedGeometryEffect(id: "SubLabel", in: animation)
                        }
                        
                    }
                    
                }
                
                Spacer(minLength: 0)
                
                if !globalVM.expand {
                    
                    if audioKit.player.isPlaying {
                        Button(action: {
                            audioKit.pause()
                        }) {
                            Image(systemName: "pause.fill")
                                .resizable()
                                .foregroundColor(.primary)
                                .frame(width: 20, height: 20)
                                .padding()
                        }
                    } else {
                        Button(action: {
                            audioKit.resume()
                        }) {
                            Image(systemName: "play.fill")
                                .resizable()
                                .foregroundColor(.primary)
                                .frame(width: 20, height: 20)
                                .padding()
                        }
                    }
                    
                }
                
            }
            .padding(.horizontal)
            .padding(.trailing, 25)
            
            VStack(spacing: 15) {
                
                Spacer(minLength: 0)
                
                if globalVM.expand {
                    Text("No lyrics available")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    
                    if globalVM.expand {
                        VStack(alignment: .leading) {
                            
                            Text(audioKit.getCurrentSong().title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fontWeight(.bold)
                                .matchedGeometryEffect(id: "Label", in: animation)
                            
                            if audioKit.getCurrentSong().subtitle != nil {
                                Text(audioKit.getCurrentSong().subtitle!)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .matchedGeometryEffect(id: "SubLabel", in: animation)
                            }
                            
                        }
                        
                        Spacer(minLength: 0)
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding()
                        }
                        
                    }
                    
                }
                .padding()
                .padding(.top, 20)
                
                // Slider view
                VStack {
                    
                    Slider(
                        value: $audioKit.position,
                        in: 0...audioKit.getDuration()) { isEditingChanged in
                            
                            if isEditingChanged {
                                audioKit.pause()
                            } else {
                                audioKit.seek(to: Int(audioKit.position))
                            }
                        }
                    
                    HStack {
                        
                        Text(audioKit.player.time.stringValue)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer(minLength: 0)
                        
                        Text(audioKit.player.media != nil ? audioKit.player.media.length.stringValue : "--:--")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                    }
                    
                }
                .padding()
                
                // Control buttons
                HStack(spacing: 25) {
                    
                    if globalVM.expand {
                        
                        // backward button
                        Button(action: {
                            print("backward")
                            audioKit.prev()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding()
                        }
                        
                        // Play/Pause button
                        Button(action: {
                            if (audioKit.player.isPlaying) {
                                audioKit.pause()
                            } else {
                                audioKit.resume()
                            }
                        }) {
                            Image(systemName: audioKit.player.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .padding()
                        }
                        
                         // forward button
                        Button(action: {
                            print("forward")
                            audioKit.next()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding()
                        }
                        
                    }
                    
                }
                .padding(.bottom, safeArea?.bottom == 0 ? 15 : (safeArea?.bottom ?? 45) + CGFloat(10))
                
            }
            // this will give strech effect
            .frame(height: globalVM.expand ? nil : 0)
            .opacity(globalVM.expand ? 1 : 0)
            
        }
        // Expanding to fullscreen animation when clicked
        .frame(maxHeight: globalVM.expand ? .infinity : 70)
        
        // Divider lin for seperating miniplayer and tab bar
        .background(
            VStack(spacing: 0) {
                
                BlurView()
                
                Divider()
                
            }
                .onTapGesture {
                    withAnimation(.spring()) { globalVM.expand = true}
                }
        )
        .cornerRadius(globalVM.expand ? 20 : 0)
        // moving miniplayer above tabbar
        // approz tab bar height is 48
        .offset(y: globalVM.expand ? 0 : -48)
        .offset(y: offset)
        .gesture(DragGesture().onEnded(onEndedDragGesture(value:)).onChanged(onChangedDragGesture(value:)))
        .ignoresSafeArea()
        .onAppear(perform: timerInterval)
        .onDisappear {
            self.timer?.invalidate()
        }
    
    }
    
    private func timerInterval() {
        self.timer = Timer.scheduledTimer(withTimeInterval: .zero, repeats: true) { _ in
            if audioKit.player.isPlaying {
                Task.init {
                    audioKit.setTimer()
                }
            }
        }
        self.timer?.fire()
    }
    
    private func onChangedDragGesture(value: DragGesture.Value) {
        if value.translation.height > 0 && globalVM.expand {
            offset = value.translation.height
        }
    }
    
    private func onEndedDragGesture(value: DragGesture.Value) {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.95)) {
            if value.translation.height + 100 > height {
                globalVM.expand = false
            }
            offset = 0
        }
    }
}

struct MiniplayerV2_Previews: PreviewProvider {
    static var previews: some View {
        @Namespace var animation
        @State var expand = false
        MiniplayerV2(animation: animation)
            .environmentObject(GlobalViewModel())
            .environmentObject(AudioKit())
    }
}
