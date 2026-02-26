// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "iScale",
    platforms: [.iOS(.v17)],
    targets: [
        .executableTarget(
            name: "iScale",
            path: "iScale"
        ),
        .testTarget(
            name: "iScaleTests",
            dependencies: ["iScale"],
            path: "iScaleTests"
        ),
    ]
)
