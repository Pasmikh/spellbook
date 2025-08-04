// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spellbook",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "Spellbook", targets: ["Spellbook"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Spellbook",
            path: "Sources/Spellbook"
        )
    ]
)