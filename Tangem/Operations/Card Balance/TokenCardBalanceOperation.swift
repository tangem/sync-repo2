//
//  TokenCardBalanceOperation.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 04.10.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import Foundation

class TokenCardBalanceOperation: CardBalanceOperation {
    
    override func handleMarketInfoLoaded(priceUSD: Double) {
        guard !isCancelled else {
            return
        }
        
        card.mult = priceUSD
        
        guard let tokenContractAddress = card.tokenContractAddress else {
            self.failOperationWith(error: "Token card contract is empty")
            return
        }
        
        let operation = TokenNetworkBalanceOperation(address: card.ethAddress, contract: tokenContractAddress) { [weak self] (result) in
            switch result {
            case .success(let value):
                self?.handleBalanceLoaded(balanceValue: value)
            case .failure(let error):
                self?.card.mult = 0
                self?.failOperationWith(error: error)
            }
        }
        operationQueue.addOperation(operation)
    }
    
    func handleBalanceLoaded(balanceValue: NSDecimalNumber) {
        guard !isCancelled else {
            return
        }
        
        card.valueUInt64 = balanceValue.uint64Value
        
        let normalisedValue = balanceValue.dividing(by: NSDecimalNumber(value: 1).multiplying(byPowerOf10: Int16(card.tokenDecimal)))
        card.walletValue = self.balanceFormatter.string(from: NSNumber(value: normalisedValue.doubleValue))!
        
        let value = normalisedValue.doubleValue * card.mult
        card.usdWalletValue = self.balanceFormatter.string(from: NSNumber(value: value))!
        
        completeOperation()
    }

}
