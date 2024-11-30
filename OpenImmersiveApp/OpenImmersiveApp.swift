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
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            MainMenu()
                .onOpenURL { url in
                    handleOpenUrl(url)
                }
        }
        .defaultSize(width: 750, height: 600)
        
        ImmersiveSpace(for: StreamModel.self) { $model in
            ImmersivePlayer(selectedStream: model!) {
                Task {
                    openWindow(id: "MainWindow")
                    await dismissImmersiveSpace()
                }
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }

    func handleOpenUrl(_ url: URL) {
        switch url.host() {
        case "open-stream":
            Task {
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
                guard let parsedStreamUrl = components.queryItems?.first(where: { $0.name == "url" })!.value else { return }
                guard let url = URL(string: parsedStreamUrl) else { return }
                
                let title = components.queryItems?.first(where: { $0.name == "title" })?.value ?? "Stream"
                let details = components.queryItems?.first(where: { $0.name == "details" })?.value ?? ""
                
                let stream = StreamModel(
                    title: title,
                    details: details,
                    url: url,
                    isSecurityScoped: false
                )
                
                let result = await openImmersiveSpace(value: stream)
                if result == .opened {
                    dismissWindow(id: "MainWindow")
                }
            }
        default:
            break;
        }
    }
}
