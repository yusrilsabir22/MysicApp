//
//  Miniplayer.swift
//  MysicApp
//
//  Created by mac on 26/06/23.
//

import SwiftUI

struct Miniplayer: View {
    
    @EnvironmentObject var globalVM: GlobalViewModel
    @EnvironmentObject var playerVM: PlayerViewModel
    @EnvironmentObject var audioKit: AudioKit
    @State var currentSong = GlobalViewModel.mock
    
    var animation: Namespace.ID
    
    @State var sliderVal = 0.0
    
    // Gesture offset
    @State var offset: CGFloat = 0
    @State var isPlaying = false
    @State var status = ""
    
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
                .onAppear {
                    globalVM.loadImage(from: currentSong.imgURL)
                }
                .frame(
                    width: globalVM.expand ? height : 55,
                    height: globalVM.expand ? height : 55
                )
                .onReceive(playerVM.$song) { newVal in
                    if newVal != nil {
                        globalVM.loadImage(from: newVal!.imgURL)
                    }
                }
                
                if !globalVM.expand {
                    
                    VStack(alignment: .leading) {
                        
                        Text(currentSong.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                            .matchedGeometryEffect(id: "Label", in: animation)
                        
                        if currentSong.subtitle != nil {
                            Text(currentSong.subtitle!)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .matchedGeometryEffect(id: "SubLabel", in: animation)
                        }
                        
                    }
                    
                }
                
                Spacer(minLength: 0)
                
                if !globalVM.expand {
                    
                    if status == "converting" {
                        ProgressView()
                    } else {
                        
                        if isPlaying{
                            Button(action: {
                                playerVM.pause()
                            }) {
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .foregroundColor(.primary)
                                    .frame(width: 20, height: 20)
                                    .padding()
                            }.disabled(status == "converting")
                        } else {
                            Button(action: {
                                playerVM.resume()
                            }) {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .foregroundColor(.primary)
                                    .frame(width: 20, height: 20)
                                    .padding()
                            }.disabled(status == "converting")
                        }
                        
                    }
                    
                }
                
            }
            .padding(.horizontal)
            .padding(.trailing, 25)
            
            VStack(spacing: 15) {
                
                Spacer(minLength: 0)
                
                if globalVM.expand {
                    if status == "converting" {
                        Text("converting...")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    Text("No lyrics available")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    
                    if globalVM.expand {
                        VStack(alignment: .leading) {
                            
                            Text(currentSong.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fontWeight(.bold)
                                .matchedGeometryEffect(id: "Label", in: animation)
                            
                            if currentSong.subtitle != nil {
                                Text(currentSong.subtitle!)
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
                        value: $playerVM.position,
                        in: 0...(playerVM.duration.seconds.isNaN ? 0 : playerVM.duration.seconds)) { isEditingChanged in
                            
                            if isEditingChanged {
                                playerVM.pause()
                            } else {
                                playerVM.seek(to: playerVM.position)
                            }
                        }.disabled(status == "converting")
                    
                    HStack {
                        
                        Text(Utility.formatSecondsToHMS(playerVM.position))
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer(minLength: 0)
                        
                        Text(Utility.formatSecondsToHMS(playerVM.duration.seconds))
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
                            playerVM.prev()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding()
                        }.disabled(status == "converting")
                        
                        // Play/Pause button
                        Button(action: {
                            if (isPlaying) {
                                playerVM.pause()
                            } else {
                                playerVM.resume()
                            }
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .padding()
                        }.disabled(status == "converting")
                        
                         // forward button
                        Button(action: {
                            print("forward")
                            playerVM.next()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding()
                        }.disabled(status == "converting")
                        
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
        .onReceive(playerVM.$song){newVal in
            if newVal != nil {
                currentSong = newVal!
            }
        }
        .onReceive(playerVM.$phase) {newVal in
            print("NEW VALUE: \(newVal)")
            switch(newVal) {
            case .play:
                self.status = "playing"
                self.isPlaying = true
            case .converting:
                self.status = "converting"
                self.isPlaying = false
            case .empty:
                self.status = ""
                self.isPlaying = false
            default:
                self.status = ""
                self.isPlaying = false
            }
        }
    
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

struct Miniplayer_Previews: PreviewProvider {
    static var previews: some View {
        @Namespace var animation
        @State var expand = false
        Miniplayer(animation: animation)
            .environmentObject(GlobalViewModel())
            .environmentObject(PlayerViewModel())
            .environmentObject(AudioKit())
    }
}
