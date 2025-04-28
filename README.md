# OpenImmersive
![OpenImmersive logo, representing a pair of red/blue anaglyphic glasses](OpenImmersiveApp/Media/openimmersive-logo.png)

_A free and open source MV-HEVC spatial & immersive video player for the Apple Vision Pro._

Maintained by [Anthony Maës](https://www.linkedin.com/in/portemantho/) & [Acute Immersive](https://acuteimmersive.com/), derived from [Spatial Player](https://github.com/mikeswanson/SpatialPlayer/) by [Mike Swanson](https://blog.mikeswanson.com/). See the [announcement on Medium](https://medium.com/@portemantho/openimmersive-the-free-and-open-source-immersive-video-player-a37f69556d16)!

The Apple Vision Pro introduced two types of stereoscopic videos: 
- *Spatial Video*, rectangular and user-created, is supported natively by the Photos App and the rest of the ecosystem.
- *Immersive Video*, wrapping 180 degrees around the viewer and professionally made, uses the same MV-HEVC encoding as Spatial Video but does not come with a system player, and it is rendered as a rectangular spatial video by `AVPlayerViewController`.

Because of significant interest in filmmakers for Immersive Video (fka. 3D VR180), many developers have built their own players, often derived from Mike's open-source Spatial Player.

OpenImmersive aims to provide this community with a more complete player, with playback controls, error handling, media loading from streaming and from the local photo gallery. The project and code are intentionally kept as concise as possible to find the right balance between turnkey readiness and modifiability.

## Features
* The xcode project contains **OpenImmersiveApp**, the visionOS app, which depends on **OpenImmersiveLib**, an easy-to-integrate Swift package that lives on its own github repository: [https://github.com/acuteimmersive/openimmersivelib](https://github.com/acuteimmersive/openimmersivelib)
* **This player only supports immersive and spatial videos in the MV-HEVC format.** Other formats will not display correctly without code modifications.
* Load a video from various sources: photo gallery, local files/documents, streaming playlist URL.
* Control playback with Play/Pause buttons, +15/-15 second buttons, and an interactable scrubber in an auto-dismiss control panel.
* Select resolution/bandwidth when streaming videos.

## Requirements
* macOS with Xcode 16 or later
* for on-device testing: visionOS 2.0 or later

## Usage
- Clone the repo
- Open the project in Xcode
- Update the signing settings (select the correct development team)
- Select the build target (visionOS Simulator or Apple Vision Pro)
- Run (⌘R)

Or install the app from the [visionOS AppStore](https://apps.apple.com/us/app/openimmersive/id6737087083).

## Integrate OpenImmersive in your project
- Open your visionOS app in xcode.
- Go to File > Add Package Dependencies...
- Copy-paste the repo URL `github.com/acuteimmersive/openimmersivelib` in the search bar at the top right of the popup.
- Click Add Package, and use `import OpenImmersive` to use the lib's classes and structs in your app.

## Contributions
While this project aims to remain relatively concise and lightweight to allow for modifiability, it needs a few more basic features and better error handling. Contributions are greatly appreciated!

Desired improvements:
- Subtitles support
- Online stream format detection
- Media drag & drop support
