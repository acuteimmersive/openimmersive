//
//  VideoPlayer.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/14/24.
//

import SwiftUI
import AVFoundation

/// Video Player Controller interfacing the underlying `AVPlayer`, exposing states and controls to the UI.
// @MainActor ensures properties are published on the main thread
// which is critical for using them in SwiftUI Views
@MainActor
@Observable
class VideoPlayer: Sendable {
    //MARK: Variables accessible to the UI
    /// The title of the current video (empty string if none).
    private(set) var title: String = ""
    /// A short description of the current video (empty string if none).
    private(set) var details: String = ""
    /// The duration in seconds of the current video (0 if none).
    private(set) var duration: Double = 0
    /// `true` if playback is currently paused, or if playback has completed.
    private(set) var paused: Bool = false
    /// `true` if playback is temporarily interrupted due to buffering.
    private(set) var buffering: Bool = false
    /// `true` if playback reached the end of the video and is no longer playing.
    private(set) var hasReachedEnd: Bool = false
    /// The bitrate of the current video stream (0 if none).
    private(set) var bitrate: Double = 0
    /// `true` if the control panel should be visible to the user.
    private(set) var shouldShowControlPanel: Bool = true {
        didSet {
            if shouldShowControlPanel {
                restartControlPanelTask()
            }
        }
    }
    
    /// The current time in seconds of the current video (0 if none).
    ///
    /// This variable is updated by video playback but can be overwritten by a scrubber, in conjunction with `scrubState`.
    var currentTime: Double = 0
    enum ScrubState {
        /// The scrubber is not active and reflects the video's current playback time.
        case notScrubbing
        /// The scrubber is active and the user is actively dragging it.
        case scrubStarted
        /// The scrubber is no longer active, the user just stopped dragging it and video playback should resume from the indicated time.
        case scrubEnded
    }
    /// The current state of the scrubber.
    var scrubState: ScrubState = .notScrubbing {
       didSet {
          switch scrubState {
          case .notScrubbing:
              break
          case .scrubStarted:
              cancelControlPanelTask()
              break
          case .scrubEnded:
              let seekTime = CMTime(seconds: currentTime, preferredTimescale: 1000)
              player.seek(to: seekTime) { [weak self] finished in
                  guard finished else {
                      return
                  }
                  Task { @MainActor in
                      self?.scrubState = .notScrubbing
                      self?.restartControlPanelTask()
                  }
              }
              hasReachedEnd = false
              break
          }
       }
    }
    
    //MARK: Private variables
    private var timeObserver: Any?
    private var durationObserver: NSKeyValueObservation?
    private var bufferingObserver: NSKeyValueObservation?
    private var dismissControlPanelTask: Task<Void, Never>?
    
    //MARK: Immutable variables
    /// The video player
    let player = AVPlayer()
    
    //MARK: Public methods
    /// Instruct the UI to reveal the control panel.
    func showControlPanel() {
        withAnimation {
            shouldShowControlPanel = true
        }
    }
    
    /// Instruct the UI to hide the control panel.
    func hideControlPanel() {
        withAnimation {
            shouldShowControlPanel = false
        }
    }
    
    /// Instruct the UI to toggle the visibility of the control panel.
    func toggleControlPanel() {
        withAnimation {
            shouldShowControlPanel.toggle()
        }
    }
    
    /// Load the indicated stream (will stop playback).
    /// - Parameters:
    ///   - stream: The model describing the stream.
    func openStream(_ stream: StreamModel) {
        // Clean up the AVPlayer first, avoid bad states
        stop()
        
        title = stream.title
        details = stream.details
        
        let playerItem = AVPlayerItem(url: stream.url)
        playerItem.preferredPeakBitRate = 200_000_000 // 200 Mbps LFG!
        player.replaceCurrentItem(with: playerItem)
        scrubState = .notScrubbing
        setupObservers()
    }
    
    /// Play or unpause media playback.
    ///
    /// If playback has reached the end of the video (`hasReachedEnd` is true), play from the beginning.
    func play() {
        if hasReachedEnd {
            player.seek(to: CMTime.zero)
        }
        player.play()
        paused = false
        hasReachedEnd = false
        restartControlPanelTask()
    }
    
    /// Pause media playback.
    func pause() {
        player.pause()
        paused = true
        restartControlPanelTask()
    }
    
    /// Jump back 15 seconds in media playback.
    func minus15() {
        guard let time = player.currentItem?.currentTime() else {
            return
        }
        let newTime = time - CMTime(seconds: 15.0, preferredTimescale: 1000)
        hasReachedEnd = false
        player.seek(to: newTime)
        restartControlPanelTask()
    }
    
    /// Jump forward 15 seconds in media playback.
    func plus15() {
        guard let time = player.currentItem?.currentTime() else {
            return
        }
        let newTime = time + CMTime(seconds: 15.0, preferredTimescale: 1000)
        hasReachedEnd = false
        player.seek(to: newTime)
        restartControlPanelTask()
    }
    
    /// Stop media playback and unload the current media.
    func stop() {
        tearDownObservers()
        player.replaceCurrentItem(with: nil)
        title = ""
        details = ""
        duration = 0
        currentTime = 0
        bitrate = 0
    }
    
    //MARK: Private methods
    /// Callback for the end of playback. Reveals the control panel if it was hidden.
    @objc private func onPlayReachedEnd() {
        Task { @MainActor in
            hasReachedEnd = true
            paused = true
            showControlPanel()
        }
    }
    
    // Observers are needed to extract the current playback time and total duration of the media
    // Tricky: the observer callback closures must capture a weak self for safety, and execute on the MainActor
    /// Set up observers to register current media duration, current playback time, current bitrate, playback end event.
    private func setupObservers() {
        if timeObserver == nil {
            let interval = CMTime(seconds: 0.1, preferredTimescale: 1000)
            timeObserver = player.addPeriodicTimeObserver(
                forInterval: interval,
                queue: .main
            ) { [weak self] time in
                Task { @MainActor in
                    if let self {
                        if let event = self.player.currentItem?.accessLog()?.events.last {
                            self.bitrate = event.indicatedBitrate
                        } else {
                            self.bitrate = 0
                        }
                        
                        switch self.scrubState {
                        case .notScrubbing:
                            self.currentTime = time.seconds
                            break
                        case .scrubStarted: return
                        case .scrubEnded: return
                        }
                    }
                }
            }
        }
        
        if durationObserver == nil, let currentItem = player.currentItem {
            durationObserver = currentItem.observe(
                \.duration,
                 options: [.new, .initial]
            ) { [weak self] item, _ in
                let duration = CMTimeGetSeconds(item.duration)
                if !duration.isNaN {
                    Task { @MainActor in
                        self?.duration = duration
                    }
                }
            }
        }
        
        if bufferingObserver == nil {
            bufferingObserver = player.observe(
                \.timeControlStatus,
                 options: [.new, .old, .initial]
            ) { [weak self] player, status in
                Task { @MainActor in
                    self?.buffering = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
                    // buffering doesn't bring up the control panel but prevents auto dismiss.
                    // auto dismiss after play resumed.
                    if (status.oldValue, status.newValue) == (.waitingToPlayAtSpecifiedRate, .playing) {
                        self?.restartControlPanelTask()
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPlayReachedEnd),
            name: AVPlayerItem.didPlayToEndTimeNotification,
            object: player.currentItem
        )
    }
    
    /// Tear down observers set up in `setupObservers()`.
    private func tearDownObservers() {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        durationObserver?.invalidate()
        durationObserver = nil
        bufferingObserver?.invalidate()
        bufferingObserver = nil
        
        NotificationCenter.default.removeObserver(
            self,
            name: AVPlayerItem.didPlayToEndTimeNotification,
            object: player.currentItem
        )
    }
    
    /// Restarts a task with a 10-second timer to auto-hide the control panel.
    private func restartControlPanelTask() {
        cancelControlPanelTask()
        dismissControlPanelTask = Task {
            try? await Task.sleep(for: .seconds(10))
            let videoIsPlaying = !paused && !hasReachedEnd && !buffering
            if !Task.isCancelled, videoIsPlaying {
                hideControlPanel()
            }
        }
    }
    
    /// Cancels the current task to dismiss the control panel, if any.
    private func cancelControlPanelTask() {
        dismissControlPanelTask?.cancel()
        dismissControlPanelTask = nil
    }
}
