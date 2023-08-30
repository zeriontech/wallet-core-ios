//
//  WalletContainerPrivateKeyTests.swift
//  ZerionTests
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import XCTest
@testable import ZerionWalletCore

class WalletContainerPrivateKeyTests: XCTestCase {
    let privateKey = "15b30fbf6d02f91412755a27ad1402f75a0068dfae968420095c6b632d54f816"
    let address = "0x7467594Dd44629415864Af5BcBf861b0C886afAD"
    let password = "12345678"

    lazy var containerData: String = {
        if let filepath = Bundle.module.path(forResource: "privateKey", ofType: "json"),
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

    func testCopy() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertNoThrow(try container.copy())
    }

    func testType() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertEqual(container.type, .privateKey)
    }

    func testPrimaryPrivateKeyDecrypt() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertEqual(try container.decryptPrimaryPrivateKey(password: password).hexString, privateKey)
    }

    func testPrimaryAddress() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        let account = try container.derivePrimaryAccount(password: password)
        XCTAssertEqual(account.address, address)
        XCTAssertNil(account.derivationPath)
        XCTAssertNil(account.index)
    }

    func testAccounts() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertEqual(container.accounts.count, 1)
    }

    func testAddressesFromIndex() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertThrowsError(try container.deriveAccount(accountIndex: 0, password: password))
        XCTAssertThrowsError(try container.deriveAccount(accountIndex: 1, password: password))
        XCTAssertThrowsError(try container.deriveAccount(accountIndex: 2, password: password))
    }

    func testAddressesFromPaths() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)

        XCTAssertThrowsError(try container.deriveAccount(derivationPath: "m/44'/60'/0'/0/0", password: password))
        XCTAssertThrowsError(try container.deriveAccount(derivationPath: "m/44'/60'/0'/0/1", password: password))
        XCTAssertThrowsError(try container.deriveAccount(derivationPath: "m/44'/60'/0'/0/2", password: password))
    }

    func testAddressesDeriveBatch() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertThrowsError(try container.deriveAccounts(fromIndex: 0, toIndex: 99, password: password))
    }

    func testPrivateKeysFromIndex() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertThrowsError(try container.decryptPrivateKey(accountIndex: 0, password: password))
        XCTAssertThrowsError(try container.decryptPrivateKey(accountIndex: 1, password: password))
        XCTAssertThrowsError(try container.decryptPrivateKey(accountIndex: 2, password: password))
    }

    func testPrivateKeysFromPaths() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertThrowsError(try container.decryptPrivateKey(derivationPath: "m/44'/60'/0'/0/0", password: password))
        XCTAssertThrowsError(try container.decryptPrivateKey(derivationPath: "m/44'/60'/0'/0/1", password: password))
        XCTAssertThrowsError(try container.decryptPrivateKey(derivationPath: "m/44'/60'/0'/0/2", password: password))
    }

    func testExport() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        let exportedData = try container.export()
        let reimported = try ZerionWalletContainer(data: exportedData)
        XCTAssertEqual(try reimported.decryptPrimaryPrivateKey(password: password).hexString, privateKey)
    }

    func testPasswordChange() throws {
        let data = Data(containerData.utf8)
        let container = try ZerionWalletContainer(data: data)
        XCTAssertEqual(try container.decryptPrimaryPrivateKey(password: password).hexString, privateKey)

        let newPassword = "abcdefg"
        try container.changePassword(old: password, new: newPassword)
        XCTAssertEqual(try container.decryptPrimaryPrivateKey(password: newPassword).hexString, privateKey)
    }
}
