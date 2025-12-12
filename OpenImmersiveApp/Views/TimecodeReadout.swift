//
//  TimecodeReadout.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës (Acute Immersive) on 5/21/25.
//

import SwiftUI
import OpenImmersive

/// A readout of the current video's time code with millisecond precision.
///
/// This class is provided as an example of view that can be injected in the ImmersivePlayer as a custom attachment.
struct TimecodeReadout: View {
    let videoPlayer: VideoPlayer
    @Binding var visible: Bool
    
    var body: some View {
        if visible {
            Text(timeString)
                .monospacedDigit()
                .font(.extraLargeTitle)
                .padding(20)
                .background {
                    Color.black.opacity(0.8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    var timeString: String {
        guard videoPlayer.currentTime > 0 else {
            return "--:--:--.---"
        }
        let timecode = Duration
            .seconds(videoPlayer.currentTime)
            .formatted(.time(pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 3)))
        
        return "\(timecode)"
    }
}

/// A button to toggle the visibility of the `TimecodeReadout`.
///
/// This class is provided as an example of view that can be injected in the ImmersivePlayer as an custom button.
struct TimecodeToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Image(systemName: "timer.square")
        }
        .toggleStyle(.button)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .tint(.clear)
    }
}

#Preview {
    TimecodeReadout(videoPlayer: VideoPlayer(), visible: .constant(true))
}
