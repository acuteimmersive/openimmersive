//
//  OpenImmersiveApp.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI
import OpenImmersive

@main
struct OpenImmersiveApp: App {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            MainMenu()
        }
        .defaultSize(width: 800, height: 800)
        
        ImmersiveSpace(for: StreamModel.self) { $model in
            let closeAction: () -> Void = {
                Task {
                    openWindow(id: "MainWindow")
                    await dismissImmersiveSpace()
                }
            }
            ImmersivePlayer(selectedStream: model!) {
                closeAction()
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
