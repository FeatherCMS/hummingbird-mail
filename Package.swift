// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hummingbird-mail",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "HummingbirdMail", targets: ["HummingbirdMail"]),
        .library(name: "MailKit", targets: ["MailKit"]),
        .library(name: "SES", targets: ["SES"]),
        .library(name: "SMTP", targets: ["SMTP"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.16.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMajor(from: "2.7.1")),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.2.0")
    ],
    targets: [
        .target(name: "HummingbirdMail", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .target(name: "SES"),
            .target(name: "SMTP"),
        ]),
        .target(name: "MailKit", dependencies: [
            .product(name: "NIO", package: "swift-nio")
        ]),
        .target(name: "SES", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "SotoSES", package: "soto"),
            .target(name: "MailKit")
        ]),
        .target(name: "SMTP", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .target(name: "MailKit")
        ]),
        .testTarget(name: "HBMailTests", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "SotoSES", package: "soto"),
            .target(name: "SES"),
            .target(name: "SMTP"),
        ])
    ]
)
