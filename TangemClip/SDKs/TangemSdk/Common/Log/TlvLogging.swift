//
//  TlvLogging.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 09.02.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation

protocol TlvLogging {
    func logTlv<T>(_ tlv: Tlv, _ value: T)
}

extension TlvLogging {
    func logTlv<T>(_ tlv: Tlv, _ value: T) {
        var tlvString = "\(tlv)"
        
        if tlv.tag.valueType != .data && tlv.tag.valueType != .hexString {
            tlvString += " (\(value))"
        }
        
        Log.tlv(tlvString)
    }
}
