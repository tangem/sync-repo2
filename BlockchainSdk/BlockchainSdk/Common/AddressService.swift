//
//  AddressService.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 20.04.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

public protocol AddressService {
    func makeAddress(from walletPublicKey: Data) -> String
    func validate(_ address: String) -> Bool
}
