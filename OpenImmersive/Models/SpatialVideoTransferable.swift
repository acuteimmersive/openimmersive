//
//  SpatialVideoTransferable.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 10/16/24.
//

import CoreTransferable

/// A representation for a spatial video selected from the Photos API
struct SpatialVideo: Transferable {
    enum Status {
        case failed, ready
    }
    let status: Status
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let (status, url): (Status, URL) = {
                let fileManager = FileManager.default
                
                let videosFolder = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("Videos")
                let newUrl = videosFolder.appendingPathComponent(received.file.lastPathComponent)
                
                if !fileManager.fileExists(atPath: newUrl.path) {
                    try? fileManager
                        .createDirectory(at: videosFolder, withIntermediateDirectories: true)
                    
                    // clean up the folder to keep the memory footprint of the app low
                    try? fileManager
                        .contentsOfDirectory(at: videosFolder, includingPropertiesForKeys: nil)
                        .forEach { file in
                            try? fileManager.removeItem(atPath: file.path)
                        }
                    
                    do {
                        try fileManager.copyItem(at: received.file, to: newUrl)
                    } catch {
                        print("Error: could not create a temporary copy of the selected spatial video: \(error)")
                        return (.failed, newUrl)
                    }
                }
                
                return (.ready, newUrl)
            }()
            
            return Self.init(status: status, url: url)
        }
    }
}
