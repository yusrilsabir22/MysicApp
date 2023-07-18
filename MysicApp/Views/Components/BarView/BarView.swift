//
//  BarView.swift
//  MysicApp
//
//  Created by mac on 30/06/23.
//

import SwiftUI

struct BarView: View {
    var value: CGFloat
    var numberOfSamples = 10
    @State var offset: CGFloat = 0
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center), content: {
            Capsule()
                .fill(Color.black.opacity(0.25))
                .frame(height: 30)
            
            Capsule()
                .fill(Color.black.opacity(0.35))
                .frame(width: offset + 20, height: 30)
                .gesture(DragGesture().onChanged({ val in
                    if val.location.x >= 20 && val.location.x <= UIScreen.main.bounds.width - 30 {
                        offset = val.location.x - 20
                    }
                }))
        
//            Capsule()
//                .fill(Color.red)
//                .frame(width: 35, height: 35)
//                .background(Circle().stroke(Color.white, lineWidth: 5))
//                .offset(x: offset)
//                .gesture(DragGesture().onChanged({ val in
//                    if val.location.x >= 20 && val.location.x <= UIScreen.main.bounds.width - 40 {
//                        offset = val.location.x - 20
//                    }
//                }))
        })
        .padding()
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        BarView(value: 2)
    }
}
