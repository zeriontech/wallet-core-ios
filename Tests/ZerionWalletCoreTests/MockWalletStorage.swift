//
//  MockWalletStorage.swift
//  ZerionTests
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation
@testable import ZerionWalletCore

class MockWalletStorage: WalletStorage {
    private var containers = [String: WalletContainer]()
    
    func count() -> Int {
        containers.values.count
    }

    func loadAll() throws -> [WalletContainer] {
        Array(containers.values)
    }

    func load(identifier: String) throws -> WalletContainer? {
        containers[identifier]
    }

    func save(wallet: WalletContainer) throws {
        containers[wallet.identifier] = wallet
    }

    func delete(identifier: String) throws {
        containers[identifier] = nil
    }

    func deleteAll() throws {
        containers.removeAll()
    }
}
