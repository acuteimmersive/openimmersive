//
//  MainMenu.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës on 10/16/24.
//

import SwiftUI

/// A simple window menu welcoming users to the app.
struct MainMenu: View {
    var body: some View {
        VStack {
            Image("openimmersive-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 255)
                .padding()
            
            Text("OpenImmersive")
                .font(.largeTitle)
            
            Text("A free and open source immersive video player for the Apple Vision Pro.")
                .font(.subheadline)
            
            StreamSources()
            
            Text("By [Anthony Maës](https://www.linkedin.com/in/portemantho/) ([Acute Immersive 🐶](https://www.acuteimmersive.com/)), derived from [Spatial Player](https://github.com/mikeswanson/SpatialPlayer/) by [Mike Swanson](https://blog.mikeswanson.com/).")
                .contentShape(.rect)
                .padding()
            
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    MainMenu()
}
