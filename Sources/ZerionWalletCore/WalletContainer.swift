//
//  WalletContainer.swift
//  Zerion
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation
import WalletCore

protocol WalletContainer {
    var identifier: String { get }

    var name: String { get set }

    var version: Int { get }

    var type: ContainerType { get }

    var accounts: [WalletAccount] { get }

    init(data: Data) throws

    func derivationPath(accountIndex: UInt32) -> String

    func deriveAccount(derivationPath: String, password: String) throws -> WalletAccount

    func deriveAccount(accountIndex: UInt32, password: String) throws -> WalletAccount

    func deriveAccounts(fromIndex: UInt32, toIndex: UInt32, password: String) throws -> [WalletAccount]

    func derivePrimaryAccount(password: String) throws -> WalletAccount

    func addAccount(derivationPath: String, password: String) throws -> WalletAccount

    func hasAccount(derivationPath: String) -> Bool

    func removeAccount(derivationPath: String) throws

    func decryptPrivateKey(derivationPath: String, password: String) throws -> Data

    func decryptPrivateKey(accountIndex: UInt32, password: String) throws -> Data

    func decryptPrimaryPrivateKey(password: String) throws -> Data

    func decryptMnemonic(password: String) throws -> String

    func changePassword(old: String, new: String) throws

    func export() throws -> Data
}

extension WalletContainer {
    func addAccount(password: String) throws -> WalletAccount {
        let index = UInt32((accounts.compactMap { $0.index }.map(Int.init).max() ?? -1) + 1)
        let path = derivationPath(accountIndex: index)
        return try addAccount(derivationPath: path, password: password)
    }
}
