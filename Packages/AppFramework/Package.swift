// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let mainName = "AppFramework"

let package = Package(
    name: mainName,
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: mainName,
            targets: [mainName])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(name: "B9Action", url: "https://github.com/b9swift/Action.git", from: "1.1.0"),
//        .package(name: "B9MulticastDelegate", url: "https://github.com/b9swift/MulticastDelegate.git", from: "1.1.0"),
        .package(name: "InterfaceApp", path: "../InterfaceApp"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: mainName,
            dependencies: [
//                "B9Action",
//                "B9MulticastDelegate",
                "InterfaceApp",
            ]),
        .testTarget(
            name: mainName + "Tests",
            dependencies: [
                Target.Dependency(stringLiteral: mainName)
            ],
            resources: [
                .process("Assets"),
            ]),
    ]
)
