//
//  TlvMapper.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 07/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

protocol TlvMapper {
    associatedtype T
    
    func map(data: Data) -> T
}

class TlvMapperFactory {
    static func getMapper<Mapper>(for tag: TlvTag) -> Mapper where Mapper: TlvMapper {
        switch tag {
            default:
            return HexStringTlvMapper() as! Mapper
        }
    }
}

class HexStringTlvMapper: TlvMapper {
    typealias T = String
    
    func map(data: Data) -> String {
        return data.toHex()
    }
}
