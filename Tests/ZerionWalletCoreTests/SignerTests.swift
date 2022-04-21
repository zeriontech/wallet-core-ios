//
//  SignerTests.swift
//  
//
//  Created by Igor Shmakov on 21.04.2022.
//

import XCTest
import WalletCore
@testable import ZerionWalletCore

class SignerTests: XCTestCase {
    let privateKey = Data(hexString: "15b30fbf6d02f91412755a27ad1402f75a0068dfae968420095c6b632d54f816")!
    
    lazy var typedData: String = {
        if let filepath = Bundle.module.path(forResource: "typedData", ofType: "json"),
            let content = try? String(contentsOfFile: filepath) {
            return content
        } else {
            fatalError("File not found")
        }
    }()
    
    func testLegacySign() throws {
        let message = Data(hexString: "85cab08f60de613ede14d37927fca4ebeb046b3d040df12dadbd13e59af2db16")!
        let signed = "69267087540a8370a23ec6e14f1c2c4d63c8d4f6062ba9ca531b93be2978" +
            "f0d824e26b6cc73ea0f8eea65fb55b351528cd7ba366f422765f7fdb7ba3f6ee27ae00"
        let result = try Signer.sign(input: .sign(message), privateKey: privateKey).hexString
        XCTAssertEqual(result, signed)
    }
    
    func testPersonalSign() throws {
        let message = "My email is john@doe.com - Thu, 21 Apr 2022 12:57:50 GMT".data(using: .utf8)!
        let signed = "16afa1b697bb2b05ff3bc748449b52e40afe819b8f2db3c8620ae5637544" +
            "b76e7727b86ea3617dde0038b206bc5e22ed895846c8f0679aaf1bbb22f1c0646dd401"
        let result = try Signer.sign(input: .personalSign(message), privateKey: privateKey).hexString
        XCTAssertEqual(result, signed)
    }
    
    func testSignTransaction() throws {
        let transaction = TransactionInput(
            chainID: Data(hexString: "01")!,
            nonce: Data(hexString: "00")!,
            gasPrice: Data(hexString: "0ab5d04c00")!,
            gas: Data(hexString: "5208")!,
            toAddress: "0x7467594dd44629415864af5bcbf861b0c886afad",
            data: Data(),
            amount: Data(hexString: "00")!
        )
        
        let signed = "f86480850ab5d04c00825208947467594dd44629415864af5bcbf861b0c886afad808026a08a" +
            "79f5d3d7bec3670cffdf8f36adbded9f566fdcd41e7628741e6aecca2c761ea0" +
            "40474ba7f53392511de1bfcea364b14956a4b0d8285f08aef6bee284abb24228"

        let result = try Signer.sign(input: .transaction(transaction), privateKey: privateKey).hexString
        XCTAssertEqual(result, signed)
    }
    
    func testSignTypedData() throws {
        let message = typedData.data(using: .utf8)!
        let signed = "fd3ce489dcbf26f8b77c40b2ff04e08f7145fac44b22c141146818a2af50938a4e9099df298c4a2b74c34100b625decaaf1bc043d7222df44d344b74550fb1de00"
        let result = try Signer.sign(input: .typedData(message), privateKey: privateKey).hexString
        XCTAssertEqual(result, signed)
    }
}
