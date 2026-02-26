# iScale

A minimal iOS app that uses your camera and AI vision to estimate the weight of objects.

## Features

- 📷 Camera-based weight estimation via OpenAI Vision API
- 📊 Measurement history
- ⚙️ Metric/Imperial unit toggle
- 🎯 Minimal black & white design
- 📱 Free with ads (AdMob)

## Requirements

- iOS 17.0+
- Xcode 16+

## Setup

1. Clone the repo
2. Open `iScale.xcodeproj` in Xcode (or use Swift Package Manager)
3. Add your OpenAI API key in `VisionService.swift`
4. Replace AdMob placeholder IDs in `AdManager.swift`
5. Build and run

## Architecture

- **SwiftUI** — declarative UI
- **MVVM-lite** — views own their state, services are singletons
- **Tab navigation** — Camera, History, Settings
- **UserDefaults** — lightweight persistence via `@AppStorage`

## Stack

Based on [preferred-ios-stack](https://github.com/chadnewbry/preferred-ios-stack).
