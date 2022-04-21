//
//  WalletError.swift
//  Zerion
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation

enum WalletError: Error {
    case mailformedContainer
    case unableToDeriveAccount
    case invalidDerivationPath
    case invalidPassword
    case invalidMnemonic
    case invalidPrivateKey
    case invalidInput
    case failedToDecryptPrivateKey
    case failedToDecryptMnemonic
    case failedToExport
    case failedToImport
    case failedToImportMnemonic
    case failedToImportPrivateKey
    case failedToAddAccount
    case failedToRemoveAccount
    case failedToChangePassword
}
