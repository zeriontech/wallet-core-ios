// swift-tools-version: 5.5.2
import PackageDescription

let package = Package(
    name: "ZerionWalletCore",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ZerionWalletCore",
            targets: ["ZerionWalletCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/trustwallet/wallet-core", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", branch: "master"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMajor(from: "1.7.2"))
    ],
    targets: [
        .target(
            name: "ZerionWalletCore",
            dependencies: [
                .product(name: "WalletCore", package: "wallet-core"),
                .product(name: "SwiftProtobuf", package: "wallet-core"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
            ]
        ),
        .testTarget(
            name: "ZerionWalletCoreTests",
            dependencies: [
                .target(name: "ZerionWalletCore")
            ],
            resources: [
                .copy("TestData/mnemonic.json"),
                .copy("TestData/privateKey.json"),
                .copy("TestData/typedData.json")
            ]
        )
    ]
)
