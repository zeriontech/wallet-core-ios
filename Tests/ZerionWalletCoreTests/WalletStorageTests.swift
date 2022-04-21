//
//  WalletStorageTest.swift
//  ZerionTests
//
//  Created by Igor Shmakov on 26.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import XCTest
@testable import ZerionWalletCore

class WalletStorageTest: XCTestCase {
    func testStorage() throws {
        let password = UUID().uuidString
        let storage = MockWalletStorage()
        let manager = ZerionWalletManager(storage: storage)

        XCTAssertNotNil(try manager.deleteAll())
        XCTAssertEqual(try manager.loadAll().count, 0)

        let wallet1 = try manager.createWalletPersist(password: password, name: nil)
        let wallet2 = try manager.createWalletPersist(password: password, name: nil)

        XCTAssertNoThrow(try manager.save(wallet: wallet1))
        XCTAssertNoThrow(try manager.save(wallet: wallet2))

        XCTAssertEqual(try manager.loadAll().count, 2)
        XCTAssertNotNil(try manager.load(identifier: wallet1.identifier))
        XCTAssertNotNil(try manager.load(identifier: wallet2.identifier))

        XCTAssertNoThrow(try manager.delete(identifier: wallet1.identifier))
        XCTAssertEqual(try manager.loadAll().count, 1)
        XCTAssertNil(try manager.load(identifier: wallet1.identifier))
        XCTAssertNotNil(try manager.load(identifier: wallet2.identifier))

        XCTAssertNoThrow(try manager.delete(identifier: wallet2.identifier))
        XCTAssertEqual(try manager.loadAll().count, 0)
        XCTAssertNil(try manager.load(identifier: wallet1.identifier))
        XCTAssertNil(try manager.load(identifier: wallet2.identifier))
    }
}
