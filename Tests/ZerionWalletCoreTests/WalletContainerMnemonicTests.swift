//
//  WalletContainerMnemonicTests.swift
//  ZerionTests
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import XCTest
@testable import ZerionWalletCore

class WalletContainerMnemonicTests: XCTestCase {
    let mnemonic = "genre allow company blind security cluster cost stock skate wait debris subway"
    let password = "12345678"

    lazy var containerData: String = {
        if let filepath = Bundle.module.path(forResource: "mnemonic", ofType: "json"),
            let content = try? String(contentsOfFile: filepath) {
            return content
        } else {
            fatalError("File not found")
        }
    }()

    func testImport() throws {
        let data = Data(containerData.utf8)
        XCTAssertNoThrow(try ZerionWalletContainer(data: data))
    }

    func testType() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertEqual(container.type, .mnemonic)
    }

    func testMnemonicDecrypt() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertEqual(try container.decryptMnemonic(password: password), mnemonic)
    }

    func testAccounts() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertEqual(container.accounts.count, 3)
        XCTAssertNoThrow(try container.removeAccount(derivationPath: container.derivationPath(accountIndex: 0)))
        XCTAssertEqual(container.accounts.count, 2)
        XCTAssertNoThrow(try container.addAccount(derivationPath: container.derivationPath(accountIndex: 3), password: password))
        XCTAssertNoThrow(try container.addAccount(password: password))
        XCTAssertEqual(container.accounts.count, 4)
    }

    func testAddressesFromIndex() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)

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
    }

    func testAddressesFromPaths() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)

        XCTAssertEqual(
            try container.deriveAccount(derivationPath: "m/44'/60'/0'/0/0", password: password).address,
            "0xED4a971eA7948B79265C3CA0b9F79D9b56c0022d"
        )

        XCTAssertEqual(
            try container.deriveAccount(derivationPath: "m/44'/60'/0'/0/1", password: password).address,
            "0x7467594Dd44629415864Af5BcBf861b0C886afAD"
        )

        XCTAssertEqual(
            try container.deriveAccount(derivationPath: "m/44'/60'/0'/0/2", password: password).address,
            "0x04b9aB3Be467cbB98f275B266952977116FF59b7"
        )
    }

    func testAddressesDeriveBatch() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        let accounts = try container.deriveAccounts(fromIndex: 0, toIndex: 99, password: password)

        XCTAssertEqual(accounts.count, 100)

        XCTAssertEqual(
            accounts[0].address,
            "0xED4a971eA7948B79265C3CA0b9F79D9b56c0022d"
        )

        XCTAssertEqual(
            accounts[1].address,
            "0x7467594Dd44629415864Af5BcBf861b0C886afAD"
        )

        XCTAssertEqual(
            accounts[2].address,
            "0x04b9aB3Be467cbB98f275B266952977116FF59b7"
        )
    }

    func testPrivateKeysFromIndex() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)

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

    func testPrivateKeysFromPaths() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)

        XCTAssertEqual(
            try container.decryptPrivateKey(derivationPath: "m/44'/60'/0'/0/0", password: password).hexString,
            "dbe95804848004ef312ee1877eb5af4eaf4692a8e04ff97649edbc3c71f4f656"
        )

        XCTAssertEqual(
            try container.decryptPrivateKey(derivationPath: "m/44'/60'/0'/0/1", password: password).hexString,
            "15b30fbf6d02f91412755a27ad1402f75a0068dfae968420095c6b632d54f816"
        )

        XCTAssertEqual(
            try container.decryptPrivateKey(derivationPath: "m/44'/60'/0'/0/2", password: password).hexString,
            "5bceb69fcc15f63cc30f44f403f9899638aa2a0758ae55719e5690e26f0ccb3b"
        )
    }

    func testDerivation() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)

        XCTAssertEqual(
            container.derivationPath(accountIndex: 0),
            "m/44'/60'/0'/0/0"
        )

        XCTAssertEqual(
            container.derivationPath(accountIndex: 1),
            "m/44'/60'/0'/0/1"
        )

        XCTAssertEqual(
            container.derivationPath(accountIndex: 2),
            "m/44'/60'/0'/0/2"
        )
    }

    func testExport() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        _ = try container.addAccount(password: password)
        let exportedData = try container.export()
        let reimported = try ZerionWalletContainer(data: exportedData)
        XCTAssertEqual(try reimported.decryptMnemonic(password: password), mnemonic)
        XCTAssertEqual(container.accounts.count, 4)
    }

    func testPasswordChange() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)

        XCTAssertEqual(
            try container.decryptPrivateKey(accountIndex: 0, password: password).hexString,
            "dbe95804848004ef312ee1877eb5af4eaf4692a8e04ff97649edbc3c71f4f656"
        )

        let newPassword = "abcdefg"

        try container.changePassword(old: password, new: newPassword)

        XCTAssertEqual(
            try container.decryptPrivateKey(accountIndex: 0, password: newPassword).hexString,
            "dbe95804848004ef312ee1877eb5af4eaf4692a8e04ff97649edbc3c71f4f656"
        )
    }
}
