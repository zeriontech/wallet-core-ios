//
//  WalletUtils.swift
//  Zerion
//
//  Created by Igor Shmakov on 10.12.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation
import WalletCore

enum WalletUtils {
    static func isValidMnemonic(_ mnemonic: String) -> Bool {
        Mnemonic.isValid(mnemonic: mnemonic)
    }

    static func isValidPrivateKey(_ privateKey: String) -> Bool {
        guard let data = Data(hexString: privateKey) else {
            return false
        }
        let coin = CoinType.ethereum
        return PrivateKey.isValid(data: data, curve: coin.curve)
    }

    static func isValidMnemonicWord(_ word: String) -> Bool {
        Mnemonic.isValidWord(word: word)
    }

    static func mnemonicWordSuggestions(_ prefix: String) -> [String] {
        Mnemonic.search(prefix: prefix)
    }
}
