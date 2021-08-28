// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MailView",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MailView",
            targets: ["MailView"]
        ),
    ],
    targets: [
        .target(name: "MailView")
    ]
)
