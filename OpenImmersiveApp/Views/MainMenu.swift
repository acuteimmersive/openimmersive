//
//  MainMenu.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës (Acute Immersive) on 10/16/24.
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
                .padding(20)
            
            Text("OpenImmersive")
                .font(.largeTitle)
            
            Text("A free and open source immersive video player for the Apple Vision Pro.")
                .font(.headline)
            
            Spacer()
            
            SourcesList()
                .padding(.vertical)
            
            Spacer()
            
            Text("OpenImmersive \(version) \nMaintained by [Anthony Maës](https://www.linkedin.com/in/portemantho/) & [Acute Immersive 🐶](https://www.acuteimmersive.com/)\nDerived from [Spatial Player](https://github.com/mikeswanson/SpatialPlayer/) by [Mike Swanson](https://blog.mikeswanson.com/)")
                .contentShape(.rect)
                .padding(.horizontal, 40)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
            
        }
        .padding()
    }
    
    var version: String {
        get {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainMenu()
        .environment(OpenImmersiveAppState())
}
