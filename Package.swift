// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "KlasorDuzenleyici",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "KlasorDuzenleyici", targets: ["KlasorDuzenleyici"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KlasorDuzenleyici",
            dependencies: [],
            path: "KlasorDuzenleyici"
        )
    ]
) 