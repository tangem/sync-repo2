//
//  CustomFeeServiceFactory.swift
//  Tangem
//
//  Created by Andrey Chukavin on 01.04.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

struct CustomFeeServiceFactory {
    let walletModel: WalletModel

    init(walletModel: WalletModel) {
        self.walletModel = walletModel
    }

    func makeService() -> CustomFeeService? {
        if let utxoTransactionFeeCalculator = walletModel.utxoTransactionFeeCalculator {
            return CustomUtxoFeeService(utxoTransactionFeeCalculator: utxoTransactionFeeCalculator)
        } else if walletModel.blockchainNetwork.blockchain.isEvm {
            return CustomEvmFeeService(blockchain: walletModel.blockchainNetwork.blockchain)
        } else {
            return nil
        }
    }
}
