//
//  ExpressTransactionBuilder.swift
//  Tangem
//
//  Created by Sergey Balashov on 21.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk
import TangemExpress

protocol ExpressTransactionBuilder {
    func makeTransaction(wallet: any WalletModel, data: ExpressTransactionData, fee: Fee) async throws -> BlockchainSdk.Transaction
    func makeApproveTransaction(wallet: any WalletModel, data: ApproveTransactionData, fee: Fee) async throws -> BlockchainSdk.Transaction
}
