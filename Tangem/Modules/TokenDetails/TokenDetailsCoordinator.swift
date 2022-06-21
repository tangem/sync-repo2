//
//  TokenDetailsCoordinator.swift
//  Tangem
//
//  Created by Alexander Osokin on 21.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

class TokenDetailsCoordinator: CoordinatorObject {
    var dismissAction: () -> Void = {}
    var popToRootAction: (PopToRootOptions) -> Void = { _ in }
    
    //MARK: - Main view model
    @Published private(set) var tokenDetailsViewModel: TokenDetailsViewModel? = nil
    
    //MARK: - Child coordinators
    @Published var sendCoordinator: SendCoordinator? = nil
    @Published var pushTxCoordinator: PushTxCoordinator? = nil
    
    //MARK: - Child view models
    @Published var pushedWebViewModel: WebViewContainerViewModel? = nil
    @Published var modalWebViewModel: WebViewContainerViewModel? = nil
    
    //MARK: - Private helpers
    @Published var emptyModel: Int? = nil //Fix single navigation link issue
    
    func start(with options: TokenDetailsCoordinator.Options) {
        tokenDetailsViewModel = TokenDetailsViewModel(cardModel: options.cardModel,
                                                      blockchainNetwork: options.blockchainNetwork,
                                                      amountType: options.amountType,
                                                      coordinator: self)
    }
}

extension TokenDetailsCoordinator {
    struct Options {
        let cardModel: CardViewModel
        let blockchainNetwork: BlockchainNetwork
        let amountType: Amount.AmountType
    }
}

extension TokenDetailsCoordinator: TokenDetailsRoutable {
    func openBuyCrypto(at url: URL, closeUrl: String, action: @escaping (String) -> Void) {
        pushedWebViewModel = WebViewContainerViewModel(url: url,
                                                       title: "wallet_button_topup".localized,
                                                       addLoadingIndicator: true,
                                                       urlActions: [
                                                        closeUrl: {[weak self] response in
                                                            self?.pushedWebViewModel = nil
                                                            action(response)
                                                        }])
    }
    
    func openSellCrypto(at url: URL, sellRequestUrl: String, action: @escaping (String) -> Void) {
        pushedWebViewModel = WebViewContainerViewModel(url: url,
                                                       title: "wallet_button_sell_crypto".localized,
                                                       addLoadingIndicator: true,
                                                       urlActions: [sellRequestUrl: action])
    }
    
    func openExplorer(at url: URL, blockchainDisplayName: String) {
        modalWebViewModel = WebViewContainerViewModel(url: url,
                                                      title: "common_explorer_format".localized(blockchainDisplayName),
                                                      withCloseButton: true)
    }
    
    func openSend(amountToSend: Amount, blockchainNetwork: BlockchainNetwork, cardViewModel: CardViewModel) {
        let coordinator = SendCoordinator()
        let options = SendCoordinator.Options(amountToSend: amountToSend,
                                              destination: nil,
                                              blockchainNetwork: blockchainNetwork,
                                              cardViewModel: cardViewModel)
        coordinator.start(with: options)
        self.sendCoordinator = coordinator
    }
    
    func openSendToSell(amountToSend: Amount, destination: String, blockchainNetwork: BlockchainNetwork, cardViewModel: CardViewModel) {
        let coordinator = SendCoordinator()
        let options = SendCoordinator.Options(amountToSend: amountToSend,
                                              destination: destination,
                                              blockchainNetwork: blockchainNetwork,
                                              cardViewModel: cardViewModel)
        coordinator.start(with: options)
        self.sendCoordinator = coordinator
    }
    
    func openPushTx(for tx: BlockchainSdk.Transaction, blockchainNetwork: BlockchainNetwork, card: CardViewModel) {
        let coordinator = PushTxCoordinator()
        let options = PushTxCoordinator.Options(tx: tx,
                                                blockchainNetwork: blockchainNetwork,
                                                cardModel: card)
        coordinator.start(with: options)
        self.pushTxCoordinator = coordinator
    }
}
