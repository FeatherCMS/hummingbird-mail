// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "hummingbird-mail",
    platforms: [
       .macOS(.v12),
    ],
    products: [
        .library(name: "HummingbirdMail", targets: ["HummingbirdMail"]),
        .library(name: "HummingbirdSESMail", targets: ["HummingbirdSESMail"]),
        .library(name: "HummingbirdSMTPMail", targets: ["HummingbirdSMTPMail"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "1.5.0"),
        .package(url: "https://github.com/feathercms/hummingbird-aws", branch: "main"),
        .package(url: "https://github.com/feathercms/hummingbird-services", branch: "main"),
        .package(url: "https://github.com/feathercms/feather-mail", branch: "main"),
    ],
    targets: [
        .target(name: "HummingbirdMail", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdServices", package: "hummingbird-services"),
            .product(name: "FeatherMail", package: "feather-mail"),
        ]),
        .target(name: "HummingbirdSESMail", dependencies: [
            .target(name: "HummingbirdMail"),
            .product(name: "HummingbirdAWS", package: "hummingbird-aws"),
            .product(name: "FeatherSESMail", package: "feather-mail"),
        ]),
        .target(name: "HummingbirdSMTPMail", dependencies: [
            .target(name: "HummingbirdMail"),
            .product(name: "FeatherSMTPMail", package: "feather-mail"),
        ]),
        .testTarget(name: "HummingbirdSMTPMailTests", dependencies: [
            .target(name: "HummingbirdSMTPMail"),
        ]),
        .testTarget(name: "HummingbirdSESMailTests", dependencies: [
            .target(name: "HummingbirdSESMail"),
        ]),
    ]
)
