//
//  HeadTracker.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 10/10/24.
//

import ARKit
import RealityKit
import SwiftUI

/// Provides a convenience interface to obtain head pose transforms and subscribing a closure to handle pose update events.
@MainActor
class HeadTracker {
    enum State {
        /// Head tracking is stopped.
        case stopped
        /// Head tracking is starting, the underlying `ARKitSession` is starting.
        case starting
        /// Head tracking is running and issuing event updates, `transform` is available.
        case running
    }
    
    /// The current state of head tracking. `transform` is only available when `state` is `.running`
    private(set) var state: State = .stopped
    
    /// The transform of the current pose of the head. This value is `nil` when `state` is not `.running`
    var transform: simd_float4x4? {
        get {
            guard state == .running,
                  let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
            else { return nil }
            return deviceAnchor.originFromAnchorTransform
        }
    }
    
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    private var subscription: EventSubscription?
    
    /// Starts head tracking by starting the underlying `ARKitSession` and subscribes to pose update events.
    /// - Parameters:
    ///   - content: The `RealityViewContent` provided by the `RealityView`'s `body` closure.
    ///   - handler: A closure that runs when the head pose update occurs.
    func start(content: RealityViewContent, _ handler: @escaping (SceneEvents.Update) -> Void) {
        guard state == .stopped else { return }
        state = .starting
        Task {
            do {
                try await session.run([worldTracking])
                state = .running
                subscription = content.subscribe(to: SceneEvents.Update.self, handler)
            } catch {
                print("Error starting ARKit session: \(error)")
                state = .stopped
            }
        }
    }
    
    /// Stops head tracking, the underlying `ARKitSession` and unsubscribes from pose update events.
    func stop() {
        guard state == .running else { return }
        state = .stopped
        session.stop()
        subscription?.cancel()
        subscription = nil
    }
}
