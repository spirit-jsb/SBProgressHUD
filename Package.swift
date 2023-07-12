// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SBProgressHUD",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(name: "SBProgressHUD", targets: ["SBProgressHUD"]),
    ],
    targets: [
        .target(name: "SBProgressHUD", path: "Sources"),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
