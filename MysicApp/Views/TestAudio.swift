//
//  TestAudio.swift
//  MysicApp
//
//  Created by mac on 21/07/23.
//

import SwiftUI
import AVFoundation

struct TestAudio: View {
    
    @State var avPlayer = AVPlayer()
    @State var pos: Double = 0
    @State var dur: Double = 0
    
    init() {
        let url = URL(string: "http://blondev.local:3000/api/v1/play/gR_qbfGkwpc.mp3")!
        self.avPlayer = AVPlayer(url: url)
        self.avPlayer.play()
        print("Duration \(self.avPlayer.currentItem?.duration)")
    }
    
    var body: some View {
        VStack {
            Slider(value: $pos, in: 0.0...dur)
        }
    }
}

struct TestAudio_Previews: PreviewProvider {
    static var previews: some View {
        TestAudio()
    }
}
