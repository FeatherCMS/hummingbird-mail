// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "hummingbird-mail",
    platforms: [
       .macOS(.v12),
    ],
    products: [
        .library(name: "FeatherMail", targets: ["FeatherMail"]),
        .library(name: "FeatherSESMail", targets: ["FeatherSESMail"]),
        .library(name: "FeatherSMTPMail", targets: ["FeatherSMTPMail"]),
        .library(name: "NIOSMTP", targets: ["NIOSMTP"]),
        .library(name: "SotoSESv2", targets: ["SotoSESv2"]),
        
        .library(name: "HummingbirdMail", targets: ["HummingbirdMail"]),
        .library(name: "HummingbirdSES", targets: ["HummingbirdSES"]),
        .library(name: "HummingbirdSMTP", targets: ["HummingbirdSMTP"]),
        
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.51.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl", from: "2.24.0"),
        .package(url: "https://github.com/soto-project/soto-core", from: "6.5.0"),
        .package(url: "https://github.com/soto-project/soto-codegenerator", from: "0.8.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "1.4.0"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-aws", branch: "main"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-services", branch: "main"),
    ],
    targets: [
        .target(name: "FeatherMail", dependencies: [
        ]),
        .target(name: "FeatherSESMail", dependencies: [
            .target(name: "FeatherMail"),
            .target(name: "SotoSESv2")
        ]),
        .target(name: "FeatherSMTPMail", dependencies: [
            .target(name: "NIOSMTP"),
            .target(name: "FeatherMail"),
        ]),
        .target(
            name: "SotoSESv2",
            dependencies: [
                .product(name: "SotoCore", package: "soto-core"),
            ],
            plugins: [
                .plugin(
                    name: "SotoCodeGeneratorPlugin",
                    package: "soto-codegenerator"
                ),
            ]
        ),
        .target(name: "NIOSMTP", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "Logging", package: "swift-log"),
        ]),
        // MARK: - HB packages
        
        .target(name: "HummingbirdMail", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdServices", package: "hummingbird-services"),
//            .product(name: "FeatherMail", package: "feather-mail"),
            .target(name: "FeatherMail"),
        ]),
        .target(name: "HummingbirdSES", dependencies: [
            .target(name: "HummingbirdMail"),
            .product(name: "HummingbirdAWS", package: "hummingbird-aws"),
            .target(name: "FeatherSESMail"),
        ]),
        .target(name: "HummingbirdSMTP", dependencies: [
            .target(name: "HummingbirdMail"),
            .target(name: "FeatherSMTPMail"),
        ]),
        
        .testTarget(name: "HummingbirdSMTPTests", dependencies: [
            .target(name: "HummingbirdSMTP"),
        ]),
        .testTarget(name: "HummingbirdSESTests", dependencies: [
            .target(name: "HummingbirdSES"),
        ]),
        
        // MARK: - feather tests
        
        .testTarget(name: "NIOSMTPTests", dependencies: [
            .target(name: "NIOSMTP"),
        ]),
    ]
)
