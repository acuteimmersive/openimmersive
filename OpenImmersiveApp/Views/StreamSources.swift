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
    @Environment(OpenImmersiveAppState.self) private var appState
    
    /// The visibility of a panel with advanced format options
    @State private var areOptionsShowing: Bool = false
    /// The visibility of a tooltip with more information about MV-HEVC encoding.
    @State private var isTooltipShowing: Bool = false
    
    var body: some View {
        @Bindable var appState = appState
        VStack(spacing: 10) {
            let selectedStream = {
                let stream = appState.selectedStream ?? StreamModel.sampleStream
                return appState.applyFormatOptions(to: stream)
            }()
            
            PlayButton() {
                playVideo(selectedStream)
            }
            
            let videoTitle = selectedStream.title
            let fieldOfView = appState.projection == .equirectangular ? "\(appState.fieldOfView)°" : ""
            
            Text("Selected video: **\(videoTitle)**")
            Text("Projection: **\(appState.projection.rawValue) \(fieldOfView)**")
            
            Divider()
                .padding(.vertical)
            
            HStack {
                SpatialVideoPicker() { stream in
                    appState.applyFormatOptions(from: stream)
                    appState.selectedStream = stream
                }
                
                FilePicker() { stream in
                    appState.applyFormatOptions(from: stream)
                    appState.selectedStream = stream
                }
                
                StreamUrlInput() { stream in
                    appState.applyFormatOptions(from: stream)
                    appState.selectedStream = stream
                }
                
                Toggle(isOn: $areOptionsShowing.animation(.interactiveSpring)) {
                    Image(systemName: "gearshape.fill")
                }
                .toggleStyle(.button)
            }
            .popover(isPresented: $areOptionsShowing) {
                VStack {
                    ProjectionPicker(projection: $appState.projection, options: [.equirectangular, .spatial, .appleImmersive])
                    
                    switch appState.projection {
                    case .equirectangular:
                        Text("The video will be projected onto a sphere with the following viewing angle, unless a different value is encoded in the file:")
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                        FormatPicker(fieldOfView: $appState.fieldOfView, options: [65, 144, 180, 360])
                        
                        Toggle(isOn: $appState.forceFov.animation(.easeInOut)) {
                            Text("Override encoded angle")
                        }
                        .fixedSize()
                    case .spatial:
                        Text("The video will render on a rectangular plane. Use this for Spatial Video.")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    case .appleImmersive:
                        Text("**Experimental!**\nThe video will render with the native player for Apple Immersive Videos.\nAIVU files created from half-equirectangular videos in the Apple Immersive Video Utility should use the Equirectangular projection.")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    Toggle(isOn: $appState.showTimecodeReadout.animation(.easeInOut)) {
                        Text("Show timecode readout")
                    }
                    .fixedSize()
                }
                .padding(.vertical, 20)
                .padding()
            }
            
            Text("This player only supports immersive and spatial videos in the MV-HEVC format. \(Image(systemName: "info.bubble\(isTooltipShowing ? "" : ".fill")"))")
                .font(.callout)
                .padding()
                .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .hoverEffect()
                .onTapGesture {
                    isTooltipShowing.toggle()
                }
                .popover(isPresented: $isTooltipShowing) {
                    Text("To convert side-by-side and over-under videos to MV-HEVC, use a tool like Andrew Hazelden's [Spatial Metadata app](https://github.com/Kartaverse/Spatial-Metadata) or Mike Swanson's [Spatial command line interface](https://blog.mikeswanson.com/spatial/).\n\nTo further convert 180 degree MV-HEVC videos to AIVU, use the [Apple Immersive Video Utility](https://support.apple.com/guide/immersive-video-utility/welcome/web) and select \"HEQU\" when prompted for an AIME file.")
                        .multilineTextAlignment(.center)
                        .contentShape(.rect)
                        .frame(minHeight: 120)
                        .padding(15)
                }
        }
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

/// A projection type picker
struct ProjectionPicker: View {
    @Binding public var projection: ProjectionOption
    public let options: [ProjectionOption]
    
    var body: some View {
        Picker(selection: $projection.animation()) {
            ForEach(options, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        } label: {
            Text("Projection:")
        }
        .pickerStyle(.palette)
        .controlSize(.large)
        .frame(maxWidth: CGFloat(300 * options.count))
        .fixedSize()
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
        projection: .equirectangular(fieldOfView: 180.0)
    )
}

#Preview(windowStyle: .automatic) {
    StreamSources()
        .environment(OpenImmersiveAppState())
}
