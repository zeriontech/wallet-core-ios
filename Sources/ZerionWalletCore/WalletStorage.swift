//
//  WalletStorage.swift
//  Zerion
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation

protocol WalletStorage {
    func count() -> Int

    func loadAll() throws -> [WalletContainer]

    func load(identifier: String) throws -> WalletContainer?

    func save(wallet: WalletContainer) throws

    func delete(identifier: String) throws

    func deleteAll() throws
}
