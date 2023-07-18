//
//  CustomAppBar.swift
//  MysicApp
//
//  Created by mac on 27/06/23.
//

import SwiftUI

struct CustomAppBar: View {
    var body: some View {
        HStack(spacing: 10) {
            
            Image("logo_mysic")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45)
                .cornerRadius(10)
            
            Text("Mysic")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .kerning(2)
            
            Spacer(minLength: 0)
            
            NavigationLink(
                destination: SearchView().navigationBarTitleDisplayMode(.inline)
            ) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.primary)
                    .padding()
            }
                
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(BlurView().ignoresSafeArea(.all, edges: .top))
    }
}

struct CustomAppBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomAppBar()
    }
}
