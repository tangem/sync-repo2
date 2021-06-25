//
//  TokenDetailsViewModel.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 25.02.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//
import SwiftUI
import BlockchainSdk
import Combine

class TokenDetailsViewModel: ViewModel {
    weak var assembly: Assembly!
    weak var navigation: NavigationCoordinator!
    weak var topupService: TopupService!
    
    var card: CardViewModel! {
        didSet {
            bind()
        }
    }
    
    var wallet: Wallet? {
        return walletModel?.wallet
    }
    
    var walletModel: WalletModel? {
        return card.walletModels?.first(where: { $0.wallet.blockchain == blockchain })
    }
    
    var incomingTransactions: [PendingTransaction] {
        walletModel?.incomingPendingTransactions ?? []
    }
    
    var outgoingTransactions: [PendingTransaction] {
        walletModel?.outgoingPendingTransactions ?? []
    }
    
    var canTopup: Bool {
        card.canTopup
    }
    
    var topupURL: URL? {
        if let wallet = wallet {
            
            if blockchain.isTestnet {
                return URL(string: blockchain.testnetTopupLink ?? "")
            }
            
            return topupService.getTopupURL(currencySymbol: blockchain.currencySymbol,
                                            walletAddress: wallet.address)
        }
        return nil
    }
    
    var topupCloseUrl: String {
        topupService.topupCloseUrl.removeLatestSlash()
    }
    
    var canSend: Bool {
        guard card.canSign else {
            return false
        }
        
        return wallet?.canSend(amountType: self.amountType) ?? false
    }
    
    var canDelete: Bool {
        guard let walletModel = self.walletModel else {
            return false
        }
        
        let canRemoveAmountType = walletModel.canRemove(amountType: amountType)
        if case .noAccount = walletModel.state, canRemoveAmountType {
            return true
        }
        
        if amountType == .coin {
            return card.canRemoveBlockchain(walletModel.wallet.blockchain)
        } else {
            return canRemoveAmountType
        }
    }
    
    var shouldShowTxNote: Bool {
        guard let walletModel = walletModel else { return false }
        
        return walletModel.wallet.hasPendingTx && !walletModel.wallet.hasPendingTx(for: amountType)
    }
    
    var txNoteMessage: String {
        guard let walletModel = walletModel else { return "" }
        
        let name = walletModel.wallet.transactions.first?.amount.currencySymbol ?? ""
        return String(format: "token_details_tx_note_message".localized, name)
    }
    
    var amountToSend: Amount? {
        wallet?.amounts[amountType]
    }
    
    var transactionToPush: BlockchainSdk.Transaction? {
        guard let index = txIndexToPush else { return nil }
        
        return wallet?.pendingOutgoingTransactions[index]
    }
    
    var title: String {
        if let token = amountType.token {
            return token.name
        } else {
            return wallet?.blockchain.displayName ?? ""
        }
    }
    
    var tokenSubtitle: String? {
        if amountType.token == nil {
            return nil
        }
        
        return blockchain.tokenDisplayName
    }
    
    @Published var isRefreshing = false
    @Published var txIndexToPush: Int? = nil
    
    let amountType: Amount.AmountType
    let blockchain: Blockchain
    private var bag = Set<AnyCancellable>()
    
    init(blockchain: Blockchain, amountType: Amount.AmountType) {
        self.blockchain = blockchain
        self.amountType = amountType
    }
    
    func onRemove() {
        if let walletModel = self.walletModel, amountType == .coin, case .noAccount = walletModel.state {
            card.removeBlockchain(walletModel.wallet.blockchain)
            return
        }

        if let walletModel = self.walletModel {
            if amountType == .coin {
                card.removeBlockchain(walletModel.wallet.blockchain)
            } else if case let .token(token) = amountType {
                walletModel.removeToken(token)
            }
        }
    }
    
    func topupAction() {
        guard
            card.isTestnet,
            let token = amountType.token,
            case .ethereum(testnet: true) = token.blockchain
        else {
            if topupURL != nil {
                navigation.detailsToTopup = true
            }
            return
        }
        
        guard let model = walletModel else { return }
        
        TestnetTopupService.topup(.erc20Token(walletManager: model.walletManager, token: token))
    }
    
    func pushOutgoingTx(at index: Int) {
        assembly.reset(key: String(describing: PushTxViewModel.Type.self))
        txIndexToPush = index
    }
    
    private func bind() {
        print("🔗 Token Details view model updates binding")
        card.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &bag)
        
        $isRefreshing
            .removeDuplicates()
            .filter { $0 }
            .sink{ [unowned self] _ in
                self.walletModel?.update()
            }
            .store(in: &bag)
        
        walletModel?
            .$state
            .removeDuplicates()
//            .print("🐼 TokenDetailsViewModel: Wallet model state")
            .map{ $0.isLoading }
            .filter { !$0 }
            .receive(on: RunLoop.main)
            .sink {[unowned self] _ in
                print("♻️ Token wallet model loading state changed")
                withAnimation {
                    self.isRefreshing = false
                }
            }
            .store(in: &bag)
        
        walletModel?.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &bag)
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
