//
//  RetryView.swift
//  MysicApp
//
//  Created by mac on 29/06/23.
//


import SwiftUI

struct RetryView: View {
    let text: String
    let retryAction: () async -> ()
    var body: some View {
        VStack(spacing: 8) {
            Text(text)
                .font(.callout)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task.init {await retryAction()}
            }) {
                Text("Try again")
            }
        }
    }
}

struct RetryView_Previews: PreviewProvider {
    static var previews: some View {
        RetryView(text: "test", retryAction: {})
    }
}
