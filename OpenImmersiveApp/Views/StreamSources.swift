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
    /// Whether to use the fallback field of view as forced value.
    @State private var forceFov: Bool = false
    /// The visibility of a panel with advanced format options
    @State private var areOptionsShowing: Bool = false
    /// The visibility of a tooltip with more information about MV-HEVC encoding.
    @State private var isTooltipShowing: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Play Sample Stream", systemImage: "play.rectangle.fill") {
                var stream = applyFormat(to: StreamModel.sampleStream)
                // lock the fallback to 180 but let users override to illustrate functionality
                stream.fallbackFieldOfView = 180.0
                playVideo(stream)
            }
            
            Divider()
                .padding(.vertical, areOptionsShowing ? 0 : 40)
            
            HStack {
                SpatialVideoPicker() { stream in
                    playVideo(applyFormat(to: stream))
                }
                
                FilePicker() { stream in
                    playVideo(applyFormat(to: stream))
                }
                
                StreamUrlInput() { stream in
                    playVideo(applyFormat(to: stream))
                }
                
                Toggle(isOn: $areOptionsShowing.animation(.interactiveSpring)) {
                    Image(systemName: "gearshape.fill")
                }
                .toggleStyle(.button)
            }
            
            if areOptionsShowing {
                VStack {
                    Text("Video format is automatically detected when possible, otherwise the player will fall back to the following value:")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom)
                    
                    FormatPicker(fieldOfView: $fallbackFov, options: [65, 144, 180, 360])
                    
                    Toggle(isOn: $forceFov.animation(.easeInOut)) {
                        Text("Override detected format")
                    }
                    .fixedSize()
                }
                .padding(.horizontal, 40)
                .padding(.vertical)
                .glassBackgroundEffect()
                .padding(.horizontal, 40)
                .transition(.scale)
            }
            
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
    
    /// Updates the input StreamModel's fallbackFieldOfView and forceFieldOfView values according to their corresponding user options.
    /// - Parameters:
    ///   - stream: the model describing the stream.
    private func applyFormat(to stream: StreamModel) -> StreamModel {
        var stream = stream
        stream.fallbackFieldOfView = Float(fallbackFov)
        stream.forceFieldOfView = forceFov ? Float(fallbackFov) : nil
        return stream
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
