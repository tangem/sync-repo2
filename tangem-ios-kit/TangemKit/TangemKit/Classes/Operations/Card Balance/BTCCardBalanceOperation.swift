//
//  BTCCardBalanceOperation.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 04.10.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import Foundation

enum BTCCardBalanceError: Error {
    case balanceIsNil
}

class BTCCardBalanceOperation: BaseCardBalanceOperation {

    override func handleMarketInfoLoaded(priceUSD: Double) {
        guard !isCancelled else {
            return
        }

        card.mult = priceUSD

        let operation = BtcBalanceOperation(with: card.cardEngine as! BTCEngine, completion: { [weak self] result in
            switch result {
            case .success(let response):
                
                let engine = self?.card.cardEngine as! BTCEngine
                engine.addressResponse = response
                self?.handleBalanceLoaded(balanceValue: "\(response.balance.rounded(blockchain: .bitcoin))")
            case .failure(let error):
                self?.card.mult = 0
                self?.failOperationWith(error: error)
            }
        })
        
        operationQueue.addOperation(operation)
    }

    func handleBalanceLoaded(balanceValue: String) {
        guard !isCancelled else {
            return
        }
        
        card.walletValue = balanceValue

        completeOperation()
    }
}

