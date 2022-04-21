//
//  Data+Hex.swift
//  ZerionTests
//
//  Created by Igor Shmakov on 24.11.2021.
//  Copyright © 2021 Zerion. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
