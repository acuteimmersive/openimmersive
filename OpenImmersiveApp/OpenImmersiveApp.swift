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
    
    /// Updates the input StreamModel's `projection` value according to the corresponding user options.
    /// - Parameters:
    ///   - stream: the model describing the stream.
    func applyFormatOptions(to stream: StreamModel) -> StreamModel {
        var stream = stream
        switch projection {
        case .equirectangular:
            stream.projection = .equirectangular(fieldOfView: Float(self.fieldOfView), force: self.forceFov)
        case .spatial:
            stream.projection = .rectangular
        case .appleImmersive:
            stream.projection = .appleImmersive
        }
        return stream
    }
    
    /// Updates user options according to the input StreamModel's `projection` value.
    /// - Parameters:
    ///   - stream: the model describing the stream.
    func applyFormatOptions(from stream: StreamModel) {
        if let projection = stream.projection {
            switch projection {
            case .equirectangular(fieldOfView: let fieldOfView, force: let force):
                self.projection = .equirectangular
                self.fieldOfView = Int(fieldOfView)
                self.forceFov = force
            case .rectangular:
                self.projection = .spatial
            case .appleImmersive:
                self.projection = .appleImmersive
            }
        }
    }
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
                appState.applyFormatOptions(from: stream)
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
