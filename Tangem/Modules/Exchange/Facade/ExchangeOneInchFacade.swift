//
//  ExchangeOneInchFacade.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 08.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk
import ExchangeSdk

class ExchangeOneInchFacade: ExchangeFacade {
    @Injected(\.exchangeOneInchService) private var exchangeService: ExchangeServiceProtocol

    let exchangeManager: ExchangeManager
    let signer: TangemSigner

    private let blockchainNetwork: BlockchainNetwork
    private var bag = Set<AnyCancellable>()

    init(exchangeManager: ExchangeManager, signer: TangemSigner, blockchainNetwork: BlockchainNetwork) {
        self.exchangeManager = exchangeManager
        self.signer = signer
        self.blockchainNetwork = blockchainNetwork
    }

    // MARK: - Sending API

    func sendSwapTransaction(destinationAddress: String,
                             amount: String,
                             gas: String,
                             gasPrice: String,
                             txData: Data,
                             sourceItem: ExchangeItem) async throws {
        let decimal = Decimal(string: amount) ?? 0
        let amount = sourceItem.currency.createAmount(with: decimal)

        let gasPrice = Decimal(string: gasPrice) ?? 0
        let gasValue = Decimal(string: gas) ?? 0 * gasPrice / blockchainNetwork.blockchain.decimalValue

        let tx = try buildTransaction(gas: gasValue, destinationAddress: destinationAddress, txData: txData, amount: amount)
        return try await exchangeManager.send(tx, signer: signer)
    }

    func submitPermissionForToken(destinationAddress: String,
                                  gasPrice: String,
                                  txData: Data,
                                  for item: ExchangeItem) async throws {
        let amount = item.currency.createAmount(with: 0)

        let blockchain = blockchainNetwork.blockchain
        let fees = try await exchangeManager.getFee(amount: amount, destination: destinationAddress)
        let fee: Amount = fees[1]
        let decimalGasPrice = Decimal(string: gasPrice) ?? 0
        let gasValue = fee.value * decimalGasPrice / blockchain.decimalValue

        let tx = try buildTransaction(gas: gasValue,
                                      destinationAddress: destinationAddress,
                                      txData: txData,
                                      amount: amount)

        return try await exchangeManager.send(tx, signer: signer)
    }

    // MARK: - Swap API

    func fetchTxDataForSwap(amount: String,
                            slippage: Int,
                            items: ExchangeItems) async throws -> ExchangeSwapDataModel {

        let parameters = SwapParameters(fromTokenAddress: items.sourceItem.tokenAddress,
                                        toTokenAddress: items.destinationItem.tokenAddress,
                                        amount: amount,
                                        fromAddress: exchangeManager.walletAddress,
                                        slippage: 1)

        let result = await exchangeService.swap(blockchain: ExchangeBlockchain.convert(from: blockchainNetwork),
                                                parameters: parameters)

        switch result {
        case .success(let swapData):
            let model = ExchangeSwapDataModel(swapData: swapData)
            return model
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Approve API

    func fetchExchangeAmountLimit(for item: ExchangeItem) async throws {
        guard case .token = item.currency.type else { return }

        let contractAddress: String = item.tokenAddress
        let parameters = ApproveAllowanceParameters(tokenAddress: contractAddress, walletAddress: exchangeManager.walletAddress)

        let allowanceResult = await exchangeService.allowance(blockchain: ExchangeBlockchain.convert(from: blockchainNetwork),
                                                              allowanceParameters: parameters)

        switch allowanceResult {
        case .success(let allowanceInfo):
            item.allowance = Decimal(string: allowanceInfo.allowance) ?? 0
        case .failure(let error):
            throw error
        }
    }

    func approveTxData(for item: ExchangeItem) async throws -> ExchangeApprovedDataModel {
        let parameters = ApproveTransactionParameters(tokenAddress: item.tokenAddress, amount: .infinite)
        let txResponse = await exchangeService.approveTransaction(blockchain: ExchangeBlockchain.convert(from: blockchainNetwork),
                                                                  approveTransactionParameters: parameters)

        switch txResponse {
        case .success(let approveTxData):
            let model = ExchangeApprovedDataModel(approveTxData: approveTxData)
            return model
        case .failure(let error):
            throw error
        }
    }

    func getSpenderAddress() async throws -> String {
        let blockchain = ExchangeBlockchain.convert(from: blockchainNetwork)

        let spender = await exchangeService.spender(blockchain: blockchain)

        switch spender {
        case .success(let spender):
            return spender.address
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Private

extension ExchangeOneInchFacade {
    private func buildTransaction(gas: Decimal, destinationAddress: String, txData: Data, amount: Amount) throws -> Transaction {
        let blockchain = blockchainNetwork.blockchain
        let gasAmount = Amount(with: blockchain, type: .coin, value: gas)

        var tx = try exchangeManager.createTransaction(amount: amount,
                                                       fee: gasAmount,
                                                       destinationAddress: destinationAddress)
        tx.params = EthereumTransactionParams(data: txData)

        return tx
    }
}
