//
//  ImmersivePlayer.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/11/24.
//

import SwiftUI
import RealityKit
import AVFoundation

/// An immersive video player, complete with UI controls
struct ImmersivePlayer: View {
    /// The singleton video player control interface.
    @Binding var videoPlayer: VideoPlayer
    
    /// The stream for which the player was open.
    ///
    /// The current implementation assumes only one media per appearance of the ImmersivePlayer.
    let selectedStream: StreamModel
    
    /// The pose tracker ensuring the position of the control panel attachment is fixed relatively to the viewer.
    private let headTracker = HeadTracker()
    
    var body: some View {
        RealityView { content, attachments in
            // Setup root entity that will remain static relatively to the head
            let root = makeRootEntity()
            content.add(root)
            headTracker.start(content: content) { _ in
                guard let headTransform = headTracker.transform else {
                    return
                }
                let headPosition = simd_make_float3(headTransform.columns.3)
                root.position = headPosition
            }
            
            // Setup video half sphere entity
            let videoScreen = await makeVideoScreen()
            root.addChild(videoScreen)
            
            // Setup ControlPanel as a floating window within the immersive scene
            if let controlPanel = attachments.entity(for: "ControlPanel") {
                controlPanel.name = "ControlPanel"
                controlPanel.position = [0, -0.5, -0.7]
                videoScreen.children.append(controlPanel)
                root.addChild(controlPanel)
            }
            
            // Setup an invisible object that will catch all taps behind the control panel
            let tapCatcher = makeTapCatcher()
            root.addChild(tapCatcher)
        } update: { content, attachments in
            // do nothing
        } attachments: {
            Attachment(id: "ControlPanel") {
                ControlPanel(videoPlayer: $videoPlayer)
                    .animation(.easeInOut(duration: 0.3), value: videoPlayer.shouldShowControlPanel)
            }
        }
        .onAppear {
            videoPlayer.openStream(selectedStream)
            videoPlayer.showControlPanel()
            videoPlayer.play()
        }
        .onDisappear {
            videoPlayer.stop()
            videoPlayer.hideControlPanel()
            headTracker.stop()
            if selectedStream.isSecurityScoped {
                selectedStream.url.stopAccessingSecurityScopedResource()
            }
        }
        .gesture(TapGesture()
            .targetedToAnyEntity()
            .onEnded { event in
                videoPlayer.toggleControlPanel()
            }
        )
    }
    
    /// Programmatically generates the root entity for the RealityView scene, and positions it at `(0, 1.2, 0)`,
    /// which is a typical position for a viewer's head while sitting on a chair.
    /// - Returns: a new root entity.
    private func makeRootEntity() -> some Entity {
        let entity = Entity()
        entity.name = "Root"
        entity.position = [0.0, 1.2, 0.0] // Origin would be the floor.
        return entity
    }
    
    /// Programmatically generates the half-sphere entity with a VideoMaterial onto which the video will be projected.
    /// - Returns: a new video screen entity. 
    private func makeVideoScreen() async -> some ModelEntity {
        let (mesh, transform) = await VideoTools.makeVideoMesh()
        let entity = ModelEntity()
        entity.name = "VideoScreen"
        entity.model = ModelComponent(
            mesh: mesh,
            materials: [VideoMaterial(avPlayer: videoPlayer.player)]
        )
        entity.transform = transform
        
        return entity
    }
    
    /// Programmatically generates a tap catching entity in the shape of a large invisible box in front of the viewer.
    /// Taps captured by this invisible shape will toggle the control panel on and off.
    /// - Parameters:
    ///   - debug: if `true`, will make the box red for debug purposes (default false).
    /// - Returns: a new tap catcher entity.
    private func makeTapCatcher(debug: Bool = false) -> some Entity {
        let collisionShape: ShapeResource =
            .generateBox(width: 100, height: 100, depth: 1)
            .offsetBy(translation: [0.0, 0.0, -5.0])
        
        let entity = debug ?
        ModelEntity(
            mesh: MeshResource(shape: collisionShape),
            materials: [UnlitMaterial(color: .red)]
        ) : Entity()
        
        entity.name = "TapCatcher"
        entity.components.set(CollisionComponent(shapes: [collisionShape], mode: .trigger, filter: .default))
        entity.components.set(InputTargetComponent())
        
        return entity
    }
}
