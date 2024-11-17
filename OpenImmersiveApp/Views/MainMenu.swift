//
//  MainMenu.swift
//  OpenImmersiveApp
//
//  Created by Anthony Maës on 10/16/24.
//

import SwiftUI

/// A simple window menu welcoming users to the app.
struct MainMenu: View {
    /// The visibility of a tooltip with more information about MV-HEVC encoding.
    @State var isTooltipShowing: Bool = false
    
    var body: some View {
        VStack {
            Image("openimmersive-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 255)
                .padding()
            
            Text("OpenImmersive")
                .font(.largeTitle)
            
            Text("A free and open source immersive video player for the Apple Vision Pro.")
                .font(.subheadline)
            
            StreamSources()
            
            Text("This player supports square, 180 degree MV-HEVC videos only. \(Image(systemName: "info.bubble.fill"))")
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
            
            Text("By [Anthony Maës](https://www.linkedin.com/in/portemantho/) ([Acute Immersive 🐶](https://www.acuteimmersive.com/)), derived from [Spatial Player](https://github.com/mikeswanson/SpatialPlayer/) by [Mike Swanson](https://blog.mikeswanson.com/).")
                .contentShape(.rect)
                .padding()
            
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    MainMenu()
}
