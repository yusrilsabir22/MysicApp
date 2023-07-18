//
//  CustomSlider.swift
//  MysicApp
//
//  Created by mac on 04/07/23.
//

import SwiftUI

struct CustomSlider: View {
    
    @State var offsetX: CGFloat = 0
    @State var isActive: Bool = false
    @State var height: CGFloat = 10
    @State var value: Double = 5
    @State var timer: Timer = Timer()
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: height)
                    .gesture(
                        DragGesture().onChanged({ val in
                            if val.location.x >= height && val.location.x <= size.width  {
                                offsetX = val.location.x - height
                            }
                        })
                    )
                    .onTapGesture {
                        let x = $0.x
                        offsetX = x - height
                    }
                Capsule()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                    .frame(width: offsetX+height, height: height)
                    .gesture(
                        DragGesture().onChanged({ val in
                            if val.location.x >= height && (val.location.x-height) <= size.width  {
                                offsetX = val.location.x - height
                            }
                        })
                    )
                    .onTapGesture {
                        let x = $0.x
                        offsetX = x - height
                    }
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: height, height: height)
                    .offset(x: offsetX)
                    .gesture(
                        DragGesture().onChanged({ val in
                            if val.location.x >= height && val.location.x <= size.width  {
                                offsetX = val.location.x - height
                            }
                        })
                    )
//                    Slider(
            }
            .pressEvent(onPress: {
                withAnimation(.easeOut(duration: 0.1)) {
                    isActive = true
                    height = 15
                }
                
            }, onRelease: {
                withAnimation(.easeOut(duration: 0.1)) {
                    isActive = false
                    height = 10
                }
            })
            .padding(.top, size.height * 0.5)
        }
        .onAppear {
            for i in 0..<100 {
                print(i)
                DispatchQueue.main.async {
                    self.offsetX = CGFloat(i/100)
                }
            }
        }
    }
}

struct CustomSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomSlider()
            .preferredColorScheme(.dark)
    }
}
