// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "LIFX-Protocol",
    products: [
        .library(
            name: "LIFXProtocol",
            targets: ["LIFXProtocol"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LIFX/swift-byte-buffer", .branch("main")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMinor(from: "9.2.0")),
    ],
    targets: [
        .target(
            name: "LIFXProtocol",
            dependencies: ["ByteBuffer"]),
        .testTarget(
            name: "LIFXProtocolTests",
            dependencies: ["LIFXProtocol", "Nimble"]),
    ]
)
