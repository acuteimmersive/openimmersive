//
//  StreamSources.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI
import RealityKit

/// A list of available video stream sources.
struct StreamSources: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
        
    var body: some View {
        VStack {
            SpatialVideoPicker() { stream in
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

#Preview(windowStyle: .automatic) {
    StreamSources()
}
