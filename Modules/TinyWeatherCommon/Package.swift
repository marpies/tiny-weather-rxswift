// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TinyWeatherCommon",
    platforms: [SupportedPlatform.iOS(.v13)],
    products: [
        .library(
            name: "TWThemes",
            targets: ["TWThemes"]),
        .library(
            name: "TWExtensions",
            targets: ["TWExtensions"]),
        .library(
            name: "TWRoutes",
            targets: ["TWRoutes"]),
        .library(
            name: "TWModels",
            targets: ["TWModels"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "TWExtensions",
            dependencies: []),
        .target(
            name: "TWThemes",
            dependencies: ["TWExtensions"]),
        .target(
            name: "TWModels",
            dependencies: []),
        .target(
            name: "TWRoutes",
            dependencies: ["TWModels"]),
        .testTarget(
            name: "TinyWeatherCommonTests",
            dependencies: []),
    ]
)
