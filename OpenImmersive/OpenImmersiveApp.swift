//
//  OpenImmersiveApp.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI

@main
struct OpenImmersiveApp: App {
    /// The singleton video player control interface, passed down to the application's views.
    @State private var videoPlayer = VideoPlayer()
    
    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            MainMenu()
        }
        .defaultSize(width: 750, height: 600)
        
        ImmersiveSpace(for: StreamModel.self) { $model in
            ImmersivePlayer(videoPlayer: $videoPlayer, selectedStream: model!)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
