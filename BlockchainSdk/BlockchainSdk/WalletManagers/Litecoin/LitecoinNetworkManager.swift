//
//  LitecoinNetworkManager.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 31.01.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class LitecoinNetworkManager: BitcoinNetworkProvider {
    
    let provider: BitcoinNetworkProvider
    
    init(address: String) {
        provider = BlockcypherProvider(address: address, coin: .ltc, chain: .main)
    }
    
    func getInfo() -> Single<BitcoinResponse> {
        return provider.getInfo()
    }
    
    
    func getFee() -> AnyPublisher<BtcFee, Error> {
        return Just
    }
    
    func send(transaction: String) -> AnyPublisher<String, Error> {
        <#code#>
    }
    
    
}
