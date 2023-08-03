//
//  ZerionWalletManager.swift
//  Zerion
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation
import WalletCore

class ZerionWalletManager {
    private let storage: WalletStorage

    init(storage: WalletStorage) {
        self.storage = storage
    }
}

private extension ZerionWalletManager {
    func generateIdentifier() -> String {
        UUID().uuidString.lowercased()
    }

    func makeWalletName() -> String {
        "Wallet Group #\(count() + 1)"
    }
}

extension ZerionWalletManager: WalletManager {
    func migrateContainersIfNeeded(password: String) throws {
        for container in try loadAll() {
            let migrated = try? container.migrateVersionIfNeeded(password: password)
            if migrated ?? false {
                try? save(wallet: container)
            }
        }
    }

    func createWallet(password: String, name: String?) throws -> WalletContainer {
        guard !password.isEmpty else {
            throw WalletError.invalidPassword
        }
        let identifier = generateIdentifier()
        let storedKey = StoredKey(name: name ?? makeWalletName(), password: Data(password.utf8))
        let wallet = try ZerionWalletContainer(storedKey: storedKey, identifier: identifier, password: password)
        _ = try wallet.addAccount(password: password)
        return wallet
    }

    func importWallet(data: Data) throws -> WalletContainer {
        try ZerionWalletContainer(data: data)
    }

    func importWallet(input: String, password: String, name: String?) throws -> WalletContainer {
        if WalletUtils.isValidMnemonic(input) {
            return try importWallet(mnemonic: input, password: password, name: name)
        } else if WalletUtils.isValidPrivateKey(input) {
            return try importWallet(privateKey: input, password: password, name: name)
        } else {
            throw WalletError.failedToImport
        }
    }

    func importWallet(mnemonic: String, password: String, name: String?) throws -> WalletContainer {
        guard !password.isEmpty else {
            throw WalletError.invalidPassword
        }

        guard WalletUtils.isValidMnemonic(mnemonic) else {
            throw WalletError.invalidMnemonic
        }

        let coin = CoinType.ethereum
        let identifier = generateIdentifier()
        let storedKey = StoredKey.importHDWallet(
            mnemonic: mnemonic,
            name: name ?? makeWalletName(),
            password: Data(password.utf8),
            coin: coin
        )

        guard let storedKey = storedKey else {
            throw WalletError.failedToImportMnemonic
        }

        let wallet = try ZerionWalletContainer(storedKey: storedKey, identifier: identifier, password: password)
        return wallet
    }

    func importWallet(privateKey: String, password: String, name: String?) throws -> WalletContainer {
        guard !password.isEmpty else {
            throw WalletError.invalidPassword
        }

        guard
            WalletUtils.isValidPrivateKey(privateKey),
            let privateKeyData = Data(hexString: privateKey)
        else {
            throw WalletError.invalidPrivateKey
        }

        let coin = CoinType.ethereum
        let identifier = generateIdentifier()
        let storedKey = StoredKey.importPrivateKey(
            privateKey: privateKeyData,
            name: name ?? makeWalletName(),
            password: Data(password.utf8),
            coin: coin
        )

        guard let storedKey = storedKey else {
            throw WalletError.failedToImportPrivateKey
        }

        let wallet = try ZerionWalletContainer(storedKey: storedKey, identifier: identifier, password: password)
        _ = try wallet.addAccount(password: password)
        return wallet
    }

    func count() -> Int {
        storage.count()
    }

    func loadAll() throws -> [WalletContainer] {
        try storage.loadAll()
    }

    func load(identifier: String) throws -> WalletContainer? {
        try storage.load(identifier: identifier)
    }

    func save(wallet: WalletContainer) throws {
        try storage.save(wallet: wallet)
    }

    func delete(identifier: String) throws {
        try storage.delete(identifier: identifier)
    }

    func deleteAll() throws {
        try storage.deleteAll()
    }
}
