//
//  WalletManager.swift
//  Zerion
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation

protocol WalletManager {
    func createWallet(password: String, name: String?) throws -> WalletContainer

    func importWallet(input: String, password: String, name: String?) throws -> WalletContainer

    func importWallet(mnemonic: String, password: String, name: String?) throws -> WalletContainer

    func importWallet(privateKey: String, password: String, name: String?) throws -> WalletContainer

    func load(identifier: String) throws -> WalletContainer?

    func count() -> Int

    func loadAll() throws -> [WalletContainer]

    func save(wallet: WalletContainer) throws

    func delete(identifier: String) throws

    func deleteAll() throws
}

extension WalletManager {
    func delete(wallet: WalletContainer) throws {
        try delete(identifier: wallet.identifier)
    }

    func createWalletPersist(password: String, name: String?) throws -> WalletContainer {
        let wallet = try createWallet(password: password, name: name)
        try save(wallet: wallet)
        return wallet
    }

    func importWalletPersist(input: String, password: String, name: String?) throws -> WalletContainer {
        let wallet = try importWallet(input: input, password: password, name: name)
        try save(wallet: wallet)
        return wallet
    }

    func importWalletPersist(mnemonic: String, password: String, name: String?) throws -> WalletContainer {
        let wallet = try importWallet(mnemonic: mnemonic, password: password, name: name)
        try save(wallet: wallet)
        return wallet
    }

    func importWalletPersist(privateKey: String, password: String, name: String?) throws -> WalletContainer {
        let wallet = try importWallet(privateKey: privateKey, password: password, name: name)
        try save(wallet: wallet)
        return wallet
    }
}
