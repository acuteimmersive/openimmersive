//
//  StreamSources.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI
import RealityKit
import OpenImmersive

/// A list of available video stream sources.
struct StreamSources: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
        
    var body: some View {
        VStack {
            SpatialVideoPicker() { stream in
                playVideo(stream)
            }
            
            FilePicker() { stream in
                playVideo(stream)
            }
            
            Button("Play Sample Stream", systemImage: "play.rectangle.fill") {
                let stream = StreamModel.sampleStream
                playVideo(stream)
            }
            
            StreamUrlInput() { stream in
                playVideo(stream)
            }
        }
        .padding()
    }
    
    /// Open the immersive player and play the video for the provided stream.
    /// - Parameters:
    ///   - stream: the model describing the stream.
    ///
    /// Opening the immersive player will close the current window containing the StreamSources view.
    func playVideo(_ stream: StreamModel) {
        Task {
            let result = await openImmersiveSpace(value: stream)
            if result == .opened {
                dismissWindow()
            }
        }
    }
}

extension StreamModel {
    /// An example StreamModel to illustrate how to load videos that stream from the web.
    @MainActor public static let sampleStream = StreamModel(
        title: "Example Stream",
        details: "Local basketball player takes a shot at sunset",
        url: URL(string: "https://stream.spatialgen.com/stream/JNVc-sA-_QxdOQNnzlZTc/index.m3u8")!,
        isSecurityScoped: false
    )
}

#Preview(windowStyle: .automatic) {
    StreamSources()
}
