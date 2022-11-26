// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// https://developer.apple.com/documentation/swift_packages/package
let package = Package(
    name: "BuildSystem",
    platforms: [.macOS(.v13)],
    products: [
        // https://developer.apple.com/documentation/swift_packages/product
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(name: "BuildSystem", targets: ["BuildSystem"]),
    ],
    dependencies: [
        // https://developer.apple.com/documentation/swift_packages/target/dependency
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // https://developer.apple.com/documentation/swift_packages/target
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(name: "BuildSystem", dependencies: []),
        .testTarget(name: "ScriptTests", dependencies: ["BuildSystem"]),
    ]
)
