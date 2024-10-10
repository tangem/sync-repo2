//
//  OP_SHA1.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/08/09.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation
import CryptoSwift

// The input is hashed using SHA-1.
public struct OpSha1: OpCodeProtocol {
    public var value: UInt8 { return 0xa7 }
    public var name: String { return "OP_SHA1" }
}
