// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "hummingbird-mail",
    platforms: [
       .macOS(.v10_15),
    ],
    products: [
        .library(name: "HummingbirdMail", targets: ["HummingbirdMail"]),
        .library(name: "HummingbirdSES", targets: ["HummingbirdSES"]),
        .library(name: "HummingbirdSMTP", targets: ["HummingbirdSMTP"]),
        .library(name: "NIOSMTP", targets: ["NIOSMTP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.51.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl", from: "2.24.0"),
        .package(url: "https://github.com/soto-project/soto", from: "6.5.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "1.4.0"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-aws", branch: "main"),
    ],
    targets: [
        .target(name: "HummingbirdMail", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
        ]),
        .target(name: "HummingbirdSES", dependencies: [
            .product(name: "SotoSES", package: "soto"),
            .product(name: "HummingbirdAWS", package: "hummingbird-aws"),
            .target(name: "HummingbirdMail"),
        ]),
        .target(name: "HummingbirdSMTP", dependencies: [
            .target(name: "NIOSMTP"),
            .target(name: "HummingbirdMail"),
        ]),
        .target(name: "NIOSMTP", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "Logging", package: "swift-log"),
        ]),

        .testTarget(name: "NIOSMTPTests", dependencies: [
            .target(name: "NIOSMTP"),
        ]),
        .testTarget(name: "HummingbirdSMTPTests", dependencies: [
            .target(name: "HummingbirdSMTP"),
        ]),
        .testTarget(name: "HummingbirdSESTests", dependencies: [
            .target(name: "HummingbirdSES"),
        ]),
    ]
)
