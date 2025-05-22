//
//  PlayButton.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës (Acute Immersive) on 5/22/25.
//

import SwiftUI

/// A big play button that's easy to tap even without eye calibration.
struct PlayButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "play.fill")
        }
        .buttonStyle(PlayButtonStyle())
    }
}

/// The style definition for the big play button.
struct PlayButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        let enabledColor: Color = .white
        let disabledColor: Color = .white.opacity(0.3)
        configuration
            .label
            .font(.custom("", size: 240))
            .foregroundStyle(isEnabled ? enabledColor : disabledColor)
            .shadow(color: isEnabled ? enabledColor.opacity(0.5) : .clear, radius: 15)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .hoverEffect { effect, isActive, proxy in
                effect
                    .scaleEffect(isActive ? 1.2 : 1.0)
                    .opacity(isActive ? 1.0 : 0.8)
            }
    }
}

#Preview {
    PlayButton() {
        // nothing
    }
}
