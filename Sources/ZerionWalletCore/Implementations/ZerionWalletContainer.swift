//
//  ZerionWalletContainer.swift
//  Zerion
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation
import SwiftyJSON
import WalletCore

class ZerionWalletContainer {
    let identifier: String
    var name: String

    private(set) var version: Int
    private(set) var accounts: [WalletAccount]

    private var storedKey: StoredKey
    private let coin: CoinType

    required init(data: Data) throws {
        guard
            let container = try? JSON(data: data),
            let identifier = container[ContainerKeys.identifier.rawValue].string,
            let version = container[ContainerKeys.version.rawValue].int,
            let walletData = try? container[ContainerKeys.wallet.rawValue].rawData(),
            let storedKey = StoredKey.importJSON(json: walletData)
        else {
            throw WalletError.mailformedContainer
        }

        self.accounts = container[ContainerKeys.accounts.rawValue].arrayValue.map { account in
            WalletAccount(
                address: account[ContainerKeys.address.rawValue].stringValue,
                index: account[ContainerKeys.index.rawValue].uInt32,
                derivationPath: account[ContainerKeys.derivationPath.rawValue].string
            )
        }

        self.identifier = identifier
        self.name = container[ContainerKeys.name.rawValue].string ?? ""
        self.version = version
        self.storedKey = storedKey
        self.coin = .ethereum
        self.migrateVersionIfNeeded()
    }

    init(storedKey: StoredKey, identifier: String) {
        self.identifier = identifier
        self.name = storedKey.name
        self.version = ZerionWalletContainer.currentVersion
        self.storedKey = storedKey
        self.accounts = []
        self.coin = .ethereum
        self.migrateVersionIfNeeded()
    }
}

private extension ZerionWalletContainer {
    enum ContainerKeys: String {
        case identifier, version, wallet, accounts, name
        case address, index, derivationPath
    }

    static let currentVersion = 1

    func migrateVersionIfNeeded() {
    }

    func makeDerivationPath(accountIndex: UInt32) -> DerivationPath {
        DerivationPath(
            purpose: .bip44,
            coin: CoinType.ethereum.slip44Id,
            account: 0,
            change: 0,
            address: accountIndex
        )
    }

    func makeDerivationPath(path: String) throws -> DerivationPath {
        guard let path = DerivationPath(path) else {
            throw WalletError.invalidDerivationPath
        }
        return path
    }

    func deriveAccount(derivationPath: DerivationPath, password: String) throws -> WalletAccount {
        guard let wallet = storedKey.wallet(password: Data(password.utf8)) else {
            throw WalletError.unableToDeriveAccount
        }

        let xpub = wallet.getExtendedPublicKey(purpose: coin.purpose, coin: coin, version: .xpub)
        let pubkey = HDWallet.getPublicKeyFromExtended(extended: xpub, coin: coin, derivationPath: derivationPath.description)!
        let address = coin.deriveAddressFromPublicKey(publicKey: pubkey)

        return WalletAccount(
            address: address,
            index: derivationPath.address,
            derivationPath: derivationPath.description
        )
    }

    func decryptPrivateKey(derivationPath: DerivationPath, password: String) throws -> PrivateKey {
        guard
            let wallet = storedKey.wallet(password: Data(password.utf8))
        else {
            throw WalletError.failedToDecryptPrivateKey
        }
        return wallet.getKey(coin: coin, derivationPath: derivationPath.description)
    }
}

extension ZerionWalletContainer: WalletContainer {
    var type: ContainerType {
        storedKey.isMnemonic ? .mnemonic : .privateKey
    }

    func derivationPath(accountIndex: UInt32) -> String {
        let path = makeDerivationPath(accountIndex: accountIndex)
        return path.description
    }

    func deriveAccount(derivationPath: String, password: String) throws -> WalletAccount {
        let path = try makeDerivationPath(path: derivationPath)
        return try deriveAccount(derivationPath: path, password: password)
    }

    func deriveAccount(accountIndex: UInt32, password: String) throws -> WalletAccount {
        let path = makeDerivationPath(accountIndex: accountIndex)
        return try deriveAccount(derivationPath: path, password: password)
    }

    func deriveAccounts(fromIndex: UInt32, toIndex: UInt32, password: String) throws -> [WalletAccount] {
        guard let wallet = storedKey.wallet(password: Data(password.utf8)) else {
            throw WalletError.unableToDeriveAccount
        }

        let xpub = wallet.getExtendedPublicKey(purpose: coin.purpose, coin: coin, version: .xpub)
        var accounts: [WalletAccount] = []

        for index in fromIndex...toIndex {
            let path = makeDerivationPath(accountIndex: index)
            let pubkey = HDWallet.getPublicKeyFromExtended(extended: xpub, coin: coin, derivationPath: path.description)!
            let address = coin.deriveAddressFromPublicKey(publicKey: pubkey)
            accounts.append(
                WalletAccount(
                    address: address,
                    index: path.address,
                    derivationPath: path.description
                )
            )
        }

        return accounts
    }

    func derivePrimaryAccount(password: String) throws -> WalletAccount {
        let keyData = try decryptPrimaryPrivateKey(password: password)
        guard let privateKey = PrivateKey(data: keyData) else {
            throw WalletError.unableToDeriveAccount
        }

        return WalletAccount(
            address: coin.deriveAddress(privateKey: privateKey),
            index: nil,
            derivationPath: nil
        )
    }

    func addAccount(derivationPath: String, password: String) throws -> WalletAccount {
        switch type {
        case .privateKey:
            let account = try derivePrimaryAccount(password: password)
            accounts = [account]
            return account
        case .mnemonic:
            guard !hasAccount(derivationPath: derivationPath) else {
                throw WalletError.failedToAddAccount
            }
            let account = try deriveAccount(derivationPath: derivationPath, password: password)
            accounts.append(account)
            return account
        }
    }

    func hasAccount(derivationPath: String) -> Bool {
        accounts.contains { $0.derivationPath == derivationPath }
    }

    func removeAccount(derivationPath: String) throws {
        if let index = accounts.firstIndex(where: { $0.derivationPath == derivationPath }) {
            accounts.remove(at: index)
        } else {
            throw WalletError.failedToRemoveAccount
        }
    }

    func decryptPrivateKey(derivationPath: String, password: String) throws -> Data {
        let path = try makeDerivationPath(path: derivationPath)
        return try decryptPrivateKey(derivationPath: path, password: password).data
    }

    func decryptPrivateKey(accountIndex: UInt32, password: String) throws -> Data {
        let path = makeDerivationPath(accountIndex: accountIndex)
        return try decryptPrivateKey(derivationPath: path, password: password).data
    }

    func decryptPrimaryPrivateKey(password: String) throws -> Data {
        guard
            type == .privateKey,
            let keyData = storedKey.decryptPrivateKey(password: Data(password.utf8))
        else {
            throw WalletError.failedToDecryptPrivateKey
        }
        return keyData
    }

    func decryptMnemonic(password: String) throws -> String {
        guard
            type == .mnemonic,
            let mnemonic = storedKey.decryptMnemonic(password: Data(password.utf8))
        else {
            throw WalletError.failedToDecryptMnemonic
        }
        return mnemonic
    }

    func changePassword(old: String, new: String) throws {
        let newStoredKey: StoredKey?
        switch type {
        case .privateKey:
            let privateKeyData = try decryptPrimaryPrivateKey(password: old)
            newStoredKey = StoredKey.importPrivateKey(
                privateKey: privateKeyData,
                name: storedKey.name,
                password: Data(new.utf8),
                coin: coin
            )
        case .mnemonic:
            let mnemonic = try decryptMnemonic(password: old)
            newStoredKey = StoredKey.importHDWallet(
                mnemonic: mnemonic,
                name: storedKey.name,
                password: Data(new.utf8),
                coin: coin
            )
        }

        if let newStoredKey = newStoredKey {
            storedKey = newStoredKey
        } else {
            throw WalletError.failedToChangePassword
        }
    }

    func export() throws -> Data {
        guard
            let walletData = storedKey.exportJSON(),
            let walletJson = try? JSON(data: walletData).rawValue
        else {
            throw WalletError.failedToExport
        }
        let container = [
            ContainerKeys.identifier.rawValue: identifier,
            ContainerKeys.version.rawValue: version,
            ContainerKeys.name.rawValue: name,
            ContainerKeys.wallet.rawValue: walletJson,
            ContainerKeys.accounts.rawValue: accounts.map { account in
                [
                    ContainerKeys.address.rawValue: account.address,
                    ContainerKeys.index.rawValue: account.index as Any,
                    ContainerKeys.derivationPath.rawValue: account.derivationPath as Any
                ]
            }
        ]
        let containerJson = JSON(container)
        return try containerJson.rawData()
    }
}
