<p align="center">
    <img src="https://github.com/nerdsupremacist/Sync/raw/main/logo.png" width="600" max-width="90%" alt="Sync" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://twitter.com/nerdsupremacist">
        <img src="https://img.shields.io/badge/twitter-@nerdsupremacist-blue.svg?style=flat" alt="Twitter: @nerdsupremacist" />
    </a>
</p>

# Sync Tokamak
This provides a bridge to use [Sync](https://github.com/nerdsupremacist/Sync) with Tokamak instead of SwiftUI.

<p align="center">
    <img src="demo.gif" width="600" max-width="90%" alt="Sync" />
</p>

## Installation
### Swift Package Manager

You can install Sync Tokamak via [Swift Package Manager](https://swift.org/package-manager/) by adding the following lines to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    [...]
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Sync.git", from: "1.0.0"),
        .package(url: "https://github.com/nerdsupremacist/SyncTokamak.git", from: "0.1.0"),
    ]
)
```

## Contributions
Contributions are welcome and encouraged!

## License
Sync Sync Tokamak is available under the MIT license. See the LICENSE file for more info.
