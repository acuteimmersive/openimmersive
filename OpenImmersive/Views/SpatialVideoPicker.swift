//
//  SpatialVideoPicker.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 10/11/24.
//

import SwiftUI
import PhotosUI

/// A button revealing a `PhotosPicker` configured to only show spatial videos.
struct SpatialVideoPicker: View {
    /// The currently selected item, if any.
    @State private var selectedItem: PhotosPickerItem?
    
    /// The callback to execute after a valid spatial video has been picked.
    var urlSelectedAction: (StreamModel) -> Void
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .all(of: [.spatialMedia, .not(.images)]),
            preferredItemEncoding: .current
        ) {
            Label("Open from Gallery", systemImage: "photo.on.rectangle.angled.fill")
        }
        .photosPickerDisabledCapabilities([.search, .collectionNavigation])
        .photosPickerStyle(.presentation)
        .onChange(of: selectedItem) { _, _ in
            Task {
                do {
                    if let video = try await selectedItem?.loadTransferable(type: SpatialVideo.self),
                       video.status == .ready {
                        let stream = StreamModel(
                            title: video.url.lastPathComponent,
                            details: "From Local Gallery",
                            url: video.url,
                            isSecurityScoped: false
                        )
                        urlSelectedAction(stream)
                    }
                } catch {
                    print("Error: could not load SpatialVideo Transferable: \(error)")
                }
            }
        }
    }
}

#Preview {
    SpatialVideoPicker() { _ in
        //nothing
    }
}
