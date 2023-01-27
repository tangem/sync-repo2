//
//  DependenciesFactory.swift
//  Tangem
//
//  Created by Sergey Balashov on 28.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemExchange
import BlockchainSdk

struct SwappingModulesFactory {
    private let userWalletModel: UserWalletModel
    private let walletModel: WalletModel
    private let sender: TransactionSender
    private let signer: TransactionSigner
    private let logger: ExchangeLogger
    private let source: Currency
    private let destination: Currency?

    init(inputModel: InputModel) {
        userWalletModel = inputModel.userWalletModel
        walletModel = inputModel.walletModel
        sender = inputModel.sender
        signer = inputModel.signer
        logger = inputModel.logger
        source = inputModel.source
        destination = inputModel.destination
    }
}

// MARK: - SwappingModulesFactoring

extension SwappingModulesFactory: SwappingModulesFactoring {
    func makeSwappingViewModel(coordinator: SwappingRoutable) -> SwappingViewModel {
        SwappingViewModel(
            exchangeManager: exchangeManager(source: source, destination: destination),
            swappingDestinationService: swappingDestinationService,
            tokenIconURLBuilder: tokenIconURLBuilder,
            transactionSender: transactionSender,
            userWalletModel: userWalletModel,
            currencyMapper: currencyMapper,
            blockchainNetwork: walletModel.blockchainNetwork,
            coordinator: coordinator
        )
    }

    func makeSwappingTokenListViewModel(coordinator: SwappingTokenListRoutable) -> SwappingTokenListViewModel {
        SwappingTokenListViewModel(
            sourceCurrency: source,
            userCurrenciesProvider: userCurrenciesProvider,
            tokenIconURLBuilder: tokenIconURLBuilder,
            currencyMapper: currencyMapper,
            coordinator: coordinator
        )
    }

    func makeSwappingPermissionViewModel(
        inputModel: SwappingPermissionInputModel,
        coordinator: SwappingPermissionRoutable
    ) -> SwappingPermissionViewModel {
        SwappingPermissionViewModel(
            inputModel: inputModel,
            transactionSender: transactionSender,
            coordinator: coordinator
        )
    }

    func makeSwappingSuccessViewModel(
        inputModel: SwappingSuccessInputModel,
        coordinator: SwappingSuccessRoutable
    ) -> SwappingSuccessViewModel {
        SwappingSuccessViewModel(
            inputModel: inputModel,
            coordinator: coordinator
        )
    }
}

// MARK: Dependencies

private extension SwappingModulesFactory {
    var walletManager: WalletManager { walletModel.walletManager }

    var swappingDestinationService: SwappingDestinationServicing {
        SwappingDestinationService(walletModel: walletModel, mapper: currencyMapper)
    }

    var currencyMapper: CurrencyMapping { CurrencyMapper() }
    var tokenIconURLBuilder: TokenIconURLBuilding { TokenIconURLBuilder(baseURL: CoinsResponse.baseURL) }
    var userCurrenciesProvider: UserCurrenciesProviding { UserCurrenciesProvider(walletModel: walletModel) }
    var transactionSender: TransactionSendable {
        ExchangeTransactionSender(
            transactionCreator: walletManager,
            transactionSender: walletManager,
            transactionSigner: signer,
            currencyMapper: currencyMapper
        )
    }

    func exchangeManager(source: Currency, destination: Currency?) -> ExchangeManager {
        let networkService = BlockchainNetworkService(
            walletModel: walletModel,
            currencyMapper: currencyMapper
        )

        return TangemExchangeFactory().createExchangeManager(
            blockchainInfoProvider: networkService,
            source: source,
            destination: destination,
            logger: logger
        )
    }
}

extension SwappingModulesFactory {
    struct InputModel {
        let userWalletModel: UserWalletModel
        let walletModel: WalletModel
        let sender: TransactionSender
        let signer: TransactionSigner
        let logger: ExchangeLogger
        let source: Currency
        let destination: Currency?

        init(
            userWalletModel: UserWalletModel,
            walletModel: WalletModel,
            sender: TransactionSender,
            signer: TransactionSigner,
            logger: ExchangeLogger,
            source: Currency,
            destination: Currency? = nil
        ) {
            self.userWalletModel = userWalletModel
            self.walletModel = walletModel
            self.sender = sender
            self.signer = signer
            self.logger = logger
            self.source = source
            self.destination = destination
        }
    }
}
