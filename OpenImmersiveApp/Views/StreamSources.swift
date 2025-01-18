//
//  StreamSources.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI
import OpenImmersive

/// A list of available video stream sources.
struct StreamSources: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    /// The default field of view in case it cannot be extracted from the video asset.
    @State private var fallbackFov: Int = 180
    /// The visibility of a tooltip with more information about MV-HEVC encoding.
    @State var isTooltipShowing: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Play Sample Stream", systemImage: "play.rectangle.fill") {
                let stream = StreamModel.sampleStream
                playVideo(stream)
            }
            
            Divider()
            
            SpatialVideoPicker() { stream in
                var stream = stream
                // Override the fallback field of view with the user-specified value
                stream.fallbackFieldOfView = Float(fallbackFov)
                playVideo(stream)
            }
            
            FilePicker() { stream in
                var stream = stream
                // Override the fallback field of view with the user-specified value
                stream.fallbackFieldOfView = Float(fallbackFov)
                playVideo(stream)
            }
            
            StreamUrlInput() { stream in
                var stream = stream
                // Override the fallback field of view with the user-specified value
                stream.fallbackFieldOfView = Float(fallbackFov)
                playVideo(stream)
            }
            
            Text("Video format is automatically detected when available,\notherwise the player will use the following value:")
                .fixedSize(horizontal: false, vertical: true)
            FormatPicker(fieldOfView: $fallbackFov, options: [65, 144, 180, 360])
            
            Text("This player only supports immersive and spatial videos in the MV-HEVC format. \(Image(systemName: "info.bubble\(isTooltipShowing ? "" : ".fill")"))")
                .font(.callout)
                .padding()
                .contentShape(.rect)
                .onTapGesture {
                    isTooltipShowing.toggle()
                }
                .popover(isPresented: $isTooltipShowing) {
                    Text("To convert side-by-side and over-under videos to MV-HEVC, please use a tool like Andrew Hazelden's [Spatial Metadata app](https://github.com/Kartaverse/Spatial-Metadata) or Mike Swanson's [Spatial command line interface](https://blog.mikeswanson.com/spatial/). This last link also points to other tools, apps and services.")
                        .contentShape(.rect)
                        .frame(minHeight: 80)
                        .padding(15)
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

/// A field of view picker
struct FormatPicker: View {
    @Binding public var fieldOfView: Int
    public let options: [Int]
    
    var body: some View {
        Picker(selection: $fieldOfView) {
            ForEach(options, id: \.self) { option in
                Text("\(option)°").tag(option)
            }
        } label: {
            Text("Open as...")
        }
        .pickerStyle(.palette)
        .controlSize(.large)
        .frame(maxWidth: CGFloat(64 * options.count))
    }
}

extension StreamModel {
    /// An example StreamModel to illustrate how to load videos that stream from the web.
    @MainActor public static let sampleStream = StreamModel(
        title: "Example Stream",
        details: "Local basketball player takes a shot at sunset",
        url: URL(string: "https://stream.spatialgen.com/stream/JNVc-sA-_QxdOQNnzlZTc/index.m3u8")!,
        fallbackFieldOfView: 180.0,
        isSecurityScoped: false
    )
}

#Preview(windowStyle: .automatic) {
    StreamSources()
}
