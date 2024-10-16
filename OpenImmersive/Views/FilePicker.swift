//
//  FilePicker.swift
//  OpenImmersive
//
//  Created by Anthony Maës on 10/17/24.
//

import SwiftUI

/// A button revealing a file importer configured to only allow the selection of videos.
struct FilePicker: View {
    /// The visibility of the file importer.
    @State private var isFileImporterShowing = false
    
    /// The callback to execute after a file has been picked.
    var urlSelectedAction: (StreamModel) -> Void
    
    var body: some View {
        Button("Open from Files", systemImage: "folder.fill") {
            isFileImporterShowing.toggle()
        }
        .fileImporter(
            isPresented: $isFileImporterShowing,
            allowedContentTypes: [.audiovisualContent]
        ) { result in
            switch result {
            case .success(let url):
                let stream = StreamModel(
                    title: url.lastPathComponent,
                    details: "From Local Files",
                    url: url,
                    isSecurityScoped: url.startAccessingSecurityScopedResource()
                )
                urlSelectedAction(stream)
                break
                
            case .failure(let error):
                print("Error: failed to load file: \(error)")
                break
            }
        }
    }
}

#Preview {
    FilePicker() { _ in
        // nothing
    }
}
