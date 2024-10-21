//
//  StreamModel.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/25/24.
//

import Foundation

/// Simple structure describing a video stream.
public struct StreamModel: Codable {
    /// The title of the video stream.
    public var title: String
    /// A short description of the video stream.
    public var details: String
    /// URL to a media, whether local or streamed from a server (m3u8).
    public var url: URL
    /// True if the media required user permission for access.
    public var isSecurityScoped: Bool
    
    /// Public initializer for visibility.
    /// - Parameters:
    ///   - title: the title of the video stream.
    ///   - details: a short description of the video stream.
    ///   - url: URL to a media, whether local or streamed from a server (m3u8).
    ///   - isSecurityScoped: true if the media required user permission for access.
    public init(title: String, details: String, url: URL, isSecurityScoped: Bool = false) {
        self.title = title
        self.details = details
        self.url = url
        self.isSecurityScoped = isSecurityScoped
    }
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
