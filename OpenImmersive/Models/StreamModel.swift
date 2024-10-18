//
//  StreamModel.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/25/24.
//

import Foundation

/// Simple structure describing a video stream.
struct StreamModel: Codable {
    /// The title of the video stream.
    var title: String
    /// A short description of the video stream.
    var details: String
    /// URL to a media, whether local or streamed from a server (m3u8).
    var url: URL
    /// True if the media required user permission for access
    var isSecurityScoped: Bool
}

extension StreamModel: Identifiable {
    public var id: String { url.absoluteString }
}

extension StreamModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension StreamModel: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
