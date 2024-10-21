//
//  ControlPanel.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI
import RealityKit

/// A simple horizontal view presenting the user with video playback controls.
public struct ControlPanel: View {
    /// The singleton video player control interface.
    @Binding var videoPlayer: VideoPlayer
    
    /// The callback to execute when the user closes the immersive player.
    let closeAction: (() -> Void)?
    
    /// Public initializer for visibility.
    /// - Parameters:
    ///   - videoPlayer: the singleton video player control interface.
    ///   - closeAction: the optional callback to execute when the user closes the immersive player.
    public init(videoPlayer: Binding<VideoPlayer>, closeAction: (() -> Void)? = nil) {
        self._videoPlayer = videoPlayer
        self.closeAction = closeAction
    }
    
    public var body: some View {
        if videoPlayer.shouldShowControlPanel {
            VStack {
                HStack {
                    Button("", systemImage: "chevron.backward") {
                        closeAction?()
                    }
                    .controlSize(.extraLarge)
                    .tint(.clear)
                    .frame(width: 100)
                    
                    MediaInfo(videoPlayer: videoPlayer)
                }
                
                HStack {
                    PlaybackButtons(videoPlayer: videoPlayer)
                    
                    Scrubber(videoPlayer: $videoPlayer)
                    
                    TimeText(videoPlayer: videoPlayer)
                }
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}

/// A simple horizontal view with a dark background presenting video title, description, and a bitrate readout.
fileprivate struct MediaInfo: View {
    /// The singleton video player control interface.
    var videoPlayer: VideoPlayer
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(videoPlayer.title.isEmpty ? "No Video Selected" : videoPlayer.title)
                    .font(.title)
                
                Text(videoPlayer.details)
                    .font(.headline)
            }
            // extra padding to keep the stack centered when the bitrate is visible
            .padding(.leading, videoPlayer.bitrate > 0 ? 120 : 0)
            Spacer()

            if videoPlayer.bitrate > 0 {
                Text("\(videoPlayer.bitrate/1_000_000, specifier: "%.1f") Mbps")
                    .frame(width: 120)
                    .monospacedDigit()
                    .foregroundStyle(color(for: videoPlayer.bitrate).opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
    }
    
    /// Evaluates the font color for the bitrate label depending on bitrate value.
    /// - Parameters:
    ///   - bitrate: the bitrate value as a `Double`
    /// - Returns: White if above 50Mbps, yellow if above 25Mbps, orange if above 10Mbps, red otherwise.
    private func color(for bitrate: Double) -> Color {
        if bitrate < 10_000_000 {
            .red
        } else if bitrate < 25_000_000 {
            .orange
        } else if bitrate < 50_000_000 {
            .yellow
        } else {
            .white
        }
    }
}

/// A simple horizontal view presenting the user with video playback control buttons.
fileprivate struct PlaybackButtons: View {
    var videoPlayer: VideoPlayer
    
    var body: some View {
        HStack {
            Button("", systemImage: "gobackward.15") {
                videoPlayer.minus15()
            }
            .controlSize(.extraLarge)
            .tint(.clear)
            .frame(width: 100)
            
            if videoPlayer.paused {
                Button("", systemImage: "play") {
                    videoPlayer.play()
                }
                .controlSize(.extraLarge)
                .tint(.clear)
                .frame(width: 100)
            } else {
                Button("", systemImage: "pause") {
                    videoPlayer.pause()
                }
                .controlSize(.extraLarge)
                .tint(.clear)
                .frame(width: 100)
            }
            
            Button("", systemImage: "goforward.15") {
                videoPlayer.plus15()
            }
            .controlSize(.extraLarge)
            .tint(.clear)
            .frame(width: 100)
        }
    }
}

/// A video scrubber made of a slider, which uses a simple state machine contained in `videoPlayer`.
/// Allows users to set the video to a specific time, while otherwise reflecting the current position in playback.
fileprivate struct Scrubber: View {
    @Binding var videoPlayer: VideoPlayer
    
    var body: some View {
        Slider(value: $videoPlayer.currentTime, in: 0...videoPlayer.duration) { scrubbing in
            if scrubbing {
                videoPlayer.scrubState = .scrubStarted
            } else {
                videoPlayer.scrubState = .scrubEnded
            }
        }
        .controlSize(.extraLarge)
        .tint(.orange.opacity(0.7))
        .background(Color.white.opacity(0.5), in: .capsule)
        .padding()
    }
}

/// A label view printing the current time and total duration of a video.
fileprivate struct TimeText: View {
    var videoPlayer: VideoPlayer
    
    var body: some View {
        let timeStr = {
            guard videoPlayer.duration > 0 else {
                return "--:-- / --:--"
            }
            let currentTime = Duration
                .seconds(videoPlayer.currentTime)
                .formatted(.time(pattern: .minuteSecond))
            let duration = Duration
                .seconds(videoPlayer.duration)
                .formatted(.time(pattern: .minuteSecond))
            
            return "\(currentTime) / \(duration)"
        }()
        
        Text(timeStr)
            .font(.headline)
            .monospacedDigit()
            .frame(width: 100)
    }
}

//#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 1200, height: 45)) {
//    ControlPanel(videoPlayer: .constant(VideoPlayer()))
//}

#Preview {
    RealityView { content, attachments in
        if let entity = attachments.entity(for: "ControlPanel") {
            content.add(entity)
        }
    } attachments: {
        Attachment(id: "ControlPanel") {
            ControlPanel(videoPlayer: .constant(VideoPlayer()))
        }
    }
}
