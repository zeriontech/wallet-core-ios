# Zerion Wallet Core

This repository contains Wallet Core used by Zerion app.

## Examples
> Check tests to see all examples.

Define wallet storage and manager:
```swift
let storage = ZerionWalletStorage(service: "com.mywallet")
let manager = ZerionWalletManager(storage: storage)
```

Import or create wallet:
```swift
let walletContainer = try manager.importWalletPersist(mnemonic: mnemonic, password: password, name: "My wallet")
// or
let walletContainer = try manager.importWalletPersist(privateKey: privateKey, password: password, name: "My wallet")
// or
let walletContainer = try manager.createWalletPersist(password: password, name: "My wallet")
```

Derive accounts with index or derivation path:
```swift
let account0 = walletContainer.deriveAccount(accountIndex: 0, password: password)
let account1 = walletContainer.deriveAccount(derivationPath: "m/44'/60'/0'/0/1", password: password)
```

Access private key via index or derivation path:
```swift
let privateKey0 = try walletContainer.decryptPrivateKey(accountIndex: 0, password: password).hexString
let privateKey1 = try walletContainer.decryptPrivateKey(derivationPath: "m/44'/60'/0'/0/1", password: password).hexString
```

Access seed phrase:
```swift
let mnemonic = walletContainer.decryptMnemonic(password: password)
```

Sign transaction:
```swift
let transaction = TransactionInput(
  chainID: ...,
  nonce: ...,
  gasPrice: ...,
  gas: ...,
  toAddress: ...,
  data: ...,
  amount: ...,
)

let signed = try Signer.sign(input: .transaction(transaction), privateKey: privateKey).hexString
```

## Installation via Swift Package Manager
#### Xcode

Select `File > Add Packages... > Add Package Dependency...` and insert git url.

#### CLI

First, create `Package.swift` that its package declaration includes:

```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "MyLibrary",
    products: [
        .library(name: "MyLibrary", targets: ["MyLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/zeriontech/zerion-wallet-core-ios.git", branch: "master"),
    ],
    targets: [
        .target(name: "MyLibrary", dependencies: ["ZerionWalletCore"]),
    ]
)
```

Then, type

```shell
$ swift build
```

## Dependencies

[TrustWalletCore](https://github.com/trustwallet/wallet-core) - low level wallet cryptography functionality, written in C++ with Swift wrappers.

[KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) - wrapper for iOS keychain.

[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - easy JSON handling with Swift.

[CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) - crypto related functions and helpers for Swift implemented in Swift.

## License

Zerion Wallet Core is available under the Apache 2.0 license. See the [LICENSE](LICENSE) file for more info.
