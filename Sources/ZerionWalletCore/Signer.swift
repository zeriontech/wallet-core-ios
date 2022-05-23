//
//  Signer.swift
//  Zerion
//
//  Created by Igor Shmakov on 21.02.2022.
//  Copyright © 2022 Zerion. All rights reserved.
//

import Foundation
import WalletCore

enum Signer {
    static func sign(input: SignerInput, privateKey: Data) throws -> Data {
        switch input {
        case .sign(let data):
            return try sign(data: data, privateKey: privateKey, addPrefix: false)
        case .personalSign(let data):
            return try sign(data: data, privateKey: privateKey, addPrefix: true)
        case .transaction(let transaction):
            return try sign(transaction: transaction, privateKey: privateKey)
        case .typedData(let data):
            return try sign(typedData: data, privateKey: privateKey)
        }
    }
}

private extension Signer {
    static func prefixedDataHash(data: Data) throws -> Data {
        let prefixString = "\u{19}Ethereum Signed Message:\n" + String(data.count)
        guard let prefixData = prefixString.data(using: .utf8) else {
            throw SignerError.failedToSign
        }
        return Hash.keccak256(data: prefixData + data)
    }

    static func sign(transaction: TransactionInput, privateKey: Data) throws -> Data {
        let input = EthereumSigningInput.with {
            $0.chainID = transaction.chainID
            $0.nonce = transaction.nonce
            $0.gasLimit = transaction.gas
            $0.toAddress = transaction.toAddress
            $0.privateKey = privateKey
            $0.transaction = EthereumTransaction.with {
                $0.contractGeneric = EthereumTransaction.ContractGeneric.with {
                    $0.data = transaction.data
                    $0.amount = transaction.amount
                }
            }
            switch transaction.type {
            case let .classic(gasPrice):
                $0.gasPrice = gasPrice
                $0.txMode = .legacy
            case let .eip1559(priorityFeePerGas, maxFeePerGas):
                $0.maxInclusionFeePerGas = priorityFeePerGas
                $0.maxFeePerGas = maxFeePerGas
                $0.txMode = .enveloped
            }
        }

        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: .fantom)
        return output.encoded
    }

    static func sign(data: Data, privateKey: Data, addPrefix: Bool) throws -> Data {
        guard let privateKey = PrivateKey(data: privateKey) else {
            throw SignerError.failedToSign
        }

        let digest = addPrefix ? try prefixedDataHash(data: data) : data
        guard let signed = privateKey.sign(digest: digest, curve: CoinType.ethereum.curve) else {
            throw SignerError.failedToSign
        }

        return signed
    }

    static func sign(typedData: Data, privateKey: Data) throws -> Data {
        guard let privateKey = PrivateKey(data: privateKey) else {
            throw SignerError.failedToSign
        }

        guard let typedDataJson = String(data: typedData, encoding: .utf8) else {
            throw SignerError.failedToSign
        }

        let digest = EthereumAbi.encodeTyped(messageJson: typedDataJson)
        guard let signed = privateKey.sign(digest: digest, curve: CoinType.ethereum.curve) else {
            throw SignerError.failedToSign
        }

        return signed
    }
}
