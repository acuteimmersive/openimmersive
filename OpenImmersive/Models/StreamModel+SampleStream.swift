//
//  StreamModel+SampleStream.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 10/16/24.
//

import Foundation

extension StreamModel {
    static let sampleStream = StreamModel(
        title: "Example Stream",
        details: "Local basketball player takes a shot at sunset",
        url: URL(string: "https://stream.spatialgen.com/stream/JNVc-sA-_QxdOQNnzlZTc/index.m3u8")!,
        isSecurityScoped: false
    )
}

