//
//  WalletManagerTests.swift
//  ZerionTests
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import XCTest
@testable import ZerionWalletCore

class WalletManagerTests: XCTestCase {
    let mnemonic = "genre allow company blind security cluster cost stock skate wait debris subway"
    let privateKey = "15b30fbf6d02f91412755a27ad1402f75a0068dfae968420095c6b632d54f816"

    func testImportMnemonic() throws {
        let password = UUID().uuidString
        let manager = ZerionWalletManager(storage: MockWalletStorage())
        let container = try manager.importWalletPersist(mnemonic: mnemonic, password: password, name: nil)

        XCTAssertEqual(container.type, .mnemonic)
        XCTAssertEqual(try container.decryptMnemonic(password: password), mnemonic)
        XCTAssertNoThrow(try container.export())
        XCTAssertTrue(container.accounts.isEmpty)

        XCTAssertEqual(
            try container.deriveAccount(accountIndex: 0, password: password).address,
            "0xED4a971eA7948B79265C3CA0b9F79D9b56c0022d"
        )

        XCTAssertEqual(
            try container.deriveAccount(accountIndex: 1, password: password).address,
            "0x7467594Dd44629415864Af5BcBf861b0C886afAD"
        )

        XCTAssertEqual(
            try container.deriveAccount(accountIndex: 2, password: password).address,
            "0x04b9aB3Be467cbB98f275B266952977116FF59b7"
        )

        XCTAssertEqual(
            try container.decryptPrivateKey(accountIndex: 0, password: password).hexString,
            "dbe95804848004ef312ee1877eb5af4eaf4692a8e04ff97649edbc3c71f4f656"
        )

        XCTAssertEqual(
            try container.decryptPrivateKey(accountIndex: 1, password: password).hexString,
            "15b30fbf6d02f91412755a27ad1402f75a0068dfae968420095c6b632d54f816"
        )

        XCTAssertEqual(
            try container.decryptPrivateKey(accountIndex: 2, password: password).hexString,
            "5bceb69fcc15f63cc30f44f403f9899638aa2a0758ae55719e5690e26f0ccb3b"
        )
    }

    func testImportPrivateKey() throws {
        let password = UUID().uuidString
        let manager = ZerionWalletManager(storage: MockWalletStorage())
        let container = try manager.importWalletPersist(privateKey: privateKey, password: password, name: nil)

        XCTAssertEqual(container.type, .privateKey)
        XCTAssertEqual(container.accounts.count, 1)
        XCTAssertEqual(try container.decryptPrimaryPrivateKey(password: password).hexString, privateKey)
        XCTAssertNoThrow(try container.export())

        XCTAssertEqual(
            try container.derivePrimaryAccount(password: password).address,
            "0x7467594Dd44629415864Af5BcBf861b0C886afAD"
        )
    }

    func testCreateWallet() throws {
        let password = UUID().uuidString
        let manager = ZerionWalletManager(storage: MockWalletStorage())
        let container = try manager.createWallet(password: password, name: nil)

        XCTAssertEqual(container.type, .mnemonic)
        XCTAssertEqual(container.accounts.count, 1)
        XCTAssertNoThrow(try container.decryptMnemonic(password: password))
        XCTAssertNoThrow(try container.export())
    }
}
