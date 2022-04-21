//
//  ZerionWalletStorage.swift
//  Zerion
//
//  Created by Igor Shmakov on 26.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation
import KeychainAccess

class ZerionWalletStorage {
    private let containerPrefix: String
    private let keychain: Keychain
    
    init(service: String, containerPrefix: String? = nil) {
        self.keychain = Keychain(service: service).attributes([String(kSecAttrIsInvisible): true])
        self.containerPrefix = containerPrefix ?? service
    }
}

private extension ZerionWalletStorage {
    func makeContainerKey(identifier: String) -> String {
        "\(containerPrefix).\(identifier)"
    }
}

extension ZerionWalletStorage: WalletStorage {
    func count() -> Int {
        keychain.allKeys().count
    }

    func loadAll() throws -> [WalletContainer] {
        try keychain.allKeys().compactMap { key in
            if let data = keychain[data: key] {
                return try ZerionWalletContainer(data: data)
            } else {
                return nil
            }
        }
    }

    func load(identifier: String) throws -> WalletContainer? {
        let key = makeContainerKey(identifier: identifier)
        if let data = keychain[data: key] {
            return try ZerionWalletContainer(data: data)
        } else {
            return nil
        }
    }

    func save(wallet: WalletContainer) throws {
        let key = makeContainerKey(identifier: wallet.identifier)
        keychain[data: key] = try wallet.export()
    }

    func delete(identifier: String) throws {
        let key = makeContainerKey(identifier: identifier)
        keychain[data: key] = nil
    }

    func deleteAll() throws {
        try keychain.removeAll()
    }
}
