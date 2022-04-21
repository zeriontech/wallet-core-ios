//
//  SigningInput.swift
//  Zerion
//
//  Created by Igor Shmakov on 21.02.2022.
//  Copyright © 2022 Zerion. All rights reserved.
//

import Foundation

enum SignerInput {
    case sign(Data)
    case personalSign(Data)
    case typedData(Data)
    case transaction(TransactionInput)
}

struct TransactionInput {
    let chainID: Data
    let nonce: Data
    let gasPrice: Data
    let gas: Data
    let toAddress: String
    let data: Data
    let amount: Data
}
