//
//  OpenImmersiveApp.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI
import OpenImmersive

enum ProjectionOption: String {
    /// The projection to use for VR180/VR360 videos.
    case equirectangular = "Equirectangular"
    /// The projection to use for Spatial videos.
    case spatial = "Spatial"
    /// The projection to use for Apple Immersive videos (AIVU).
    case appleImmersive = "AIVU"
}

@Observable
class OpenImmersiveAppState {
    /// The user-selected stream.
    var selectedStream: StreamModel?
    /// The user-selected projection for the video.
    var projection: ProjectionOption = .equirectangular
    /// The user-selected field of view in case it cannot be extracted from the video asset (equirectangular projection only).
    var fieldOfView: Int = 180
    /// Whether to force the user-selected field of view even when the MV-HEVC media encodes a field of view.
    var forceFov: Bool = false
    /// Whether to show the timecode readout view in the ImmersivePlayer.
    var showTimecodeReadout: Bool = false
}

@main
struct OpenImmersiveApp: App {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State var appState = OpenImmersiveAppState()
    
    var body: some Scene {
        WindowGroup(id: "MainWindow") {
            DropTarget() {
                MainMenu()
            } loadStreamAction: { stream in
                appState.selectedStream = stream
            }
        }
        .defaultSize(width: 800, height: 850)
        .environment(appState)
        
        ImmersiveSpace(for: StreamModel.self) { $model in
            let closeAction: CustomAction = {
                Task {
                    openWindow(id: "MainWindow")
                    await dismissImmersiveSpace()
                }
            }
            
            // customButton and customAttachment are provided for illustration purposes.
            // In order to inject multiple buttons, just nest them in a HStack.
            let customButton: CustomViewBuilder = { _ in
                TimecodeToggle(isOn: $appState.showTimecodeReadout)
            }
            let customAttachment = CustomAttachment(
                id: "TimecodeReadout",
                body: { $videoPlayer in
                    TimecodeReadout(videoPlayer: videoPlayer, visible: $appState.showTimecodeReadout)
                },
                position: [0, -0.1, 0.1],
                orientation: simd_quatf(angle: -0.5, axis: [1, 0, 0]),
                relativeToControlPanel: true
            )
            
            ImmersivePlayer(
                selectedStream: model!,
                closeAction: closeAction,
                customButtons: customButton,
                customAttachments: [customAttachment]
            )
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
