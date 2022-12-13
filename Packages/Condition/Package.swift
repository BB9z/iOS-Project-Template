// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let mainName = "B9Condition"

// https://developer.apple.com/documentation/swift_packages/package
let package = Package(
    name: mainName,
//    platforms: [.iOS(.v10), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v3)],
    products: [
        // https://developer.apple.com/documentation/swift_packages/product
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: mainName,
            targets: [mainName])
    ],
    dependencies: [
        // https://developer.apple.com/documentation/swift_packages/target/dependency
        // Dependencies declare other packages that this package depends on.
        .package(name: "B9Action", url: "https://github.com/b9swift/Action.git", from: "1.0.0")
    ],
    targets: [
        // https://developer.apple.com/documentation/swift_packages/target
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: mainName,
            dependencies: ["B9Action"]),
        .testTarget(
            name: mainName + "Tests",
            dependencies: [
                Target.Dependency(stringLiteral: mainName)
            ])
    ]
)
