//
//  CardViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 18.07.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk
import Combine
import Alamofire
import SwiftUI

struct CardPinSettings {
    var isPin1Default: Bool? = nil
    var isPin2Default: Bool? = nil
}

class CardViewModel: Identifiable, ObservableObject {
    // MARK: Services
    @Injected(\.appWarningsService) private var warningsService: AppWarningsProviding
    @Injected(\.tangemSdkProvider) private var tangemSdkProvider: TangemSdkProviding
    @Injected(\.tangemApiService) var tangemApiService: TangemApiService
    @Injected(\.userWalletListService) private var userWalletListService: UserWalletListService

    @Published private(set) var currentSecurityOption: SecurityModeOption = .longTap

    var signer: TangemSigner { config.tangemSigner }

    var cardId: String { cardInfo.card.cardId }
    var userWalletId: Data? { userWalletModel?.userWallet.userWalletId }

    var card: CardDTO {
        cardInfo.card
    }

    var walletData: DefaultWalletData {
        cardInfo.walletData
    }

    var cardPublicKey: Data { cardInfo.card.cardPublicKey }

    var supportsOnlineImage: Bool {
        config.hasFeature(.onlineImage)
    }

    var isMultiWallet: Bool {
        config.hasFeature(.multiCurrency)
    }

    var emailData: [EmailCollectedData] {
        config.emailData
    }

    var emailConfig: EmailConfig {
        config.emailConfig
    }

    var cardIdFormatted: String {
        cardInfo.cardIdFormatted
    }

    var cardIssuer: String {
        cardInfo.card.issuer.name
    }

    var cardSignedHashes: Int {
        cardInfo.card.walletSignedHashes
    }

    var artworkInfo: ArtworkInfo? {
        CardImageProvider().cardArtwork(for: cardInfo.card.cardId)?.artworkInfo
    }

    var name: String {
        cardInfo.name
    }

    var defaultName: String {
        config.cardName
    }

    var canCreateBackup: Bool {
        config.hasFeature(.backup)
    }

    var canTwin: Bool {
        config.hasFeature(.twinning)
    }

    var shouldShowWC: Bool {
        !config.getFeatureAvailability(.walletConnect).isHidden
    }

    var cardTouURL: URL? {
        config.touURL
    }

    var canCountHashes: Bool {
        config.hasFeature(.signedHashesCounter)
    }

    var supportsWalletConnect: Bool {
        config.hasFeature(.walletConnect)
    }

    // Temp for WC. Migrate to userWalletId?
    var secp256k1SeedKey: Data? {
        cardInfo.card.wallets.first(where: { $0.curve == .secp256k1 })?.publicKey
    }

    // Separate UserWalletModel and CardViewModel
    var userWalletModel: UserWalletModel?

    private var cardInfo: CardInfo
    private var cardPinSettings: CardPinSettings = CardPinSettings()
    private let stateUpdateQueue = DispatchQueue(label: "state_update_queue")
    private var tangemSdk: TangemSdk { tangemSdkProvider.sdk }
    private var config: UserWalletConfig

    var availableSecurityOptions: [SecurityModeOption] {
        var options: [SecurityModeOption] = []

        if canSetLongTap || currentSecurityOption == .longTap {
            options.append(.longTap)
        }

        if config.hasFeature(.accessCode) || currentSecurityOption == .accessCode {
            options.append(.accessCode)
        }

        if config.hasFeature(.passcode) || currentSecurityOption == .passCode {
            options.append(.passCode)
        }

        return options
    }

    var hdWalletsSupported: Bool {
        config.hasFeature(.hdWallets)
    }

    var walletModels: [WalletModel] {
        userWalletModel?.getWalletModels() ?? []
    }

    var wallets: [Wallet] {
        walletModels.map { $0.wallet }
    }

    var canSetLongTap: Bool {
        config.hasFeature(.longTap)
    }

    var longHashesSupported: Bool {
        config.hasFeature(.longHashes)
    }

    var canSend: Bool {
        config.hasFeature(.send)
    }

    var hasWallet: Bool {
        !walletModels.isEmpty
    }

    var cardSetLabel: String? {
        config.cardSetLabel
    }

    var canShowAddress: Bool {
        config.hasFeature(.receive)
    }

    var canShowSend: Bool {
        config.hasFeature(.withdrawal)
    }

    var supportedBlockchains: Set<Blockchain> {
        config.supportedBlockchains
    }

    var backupInput: OnboardingInput? {
        guard let backupSteps = config.backupSteps else { return nil }

        return OnboardingInput(steps: backupSteps,
                               cardInput: .cardModel(self),
                               welcomeStep: nil,
                               twinData: nil,
                               currentStepIndex: 0,
                               isStandalone: true)
    }

    var onboardingInput: OnboardingInput {
        OnboardingInput(steps: config.onboardingSteps,
                        cardInput: .cardModel(self),
                        welcomeStep: nil,
                        twinData: cardInfo.walletData.twinData,
                        currentStepIndex: 0)
    }

    var twinInput: OnboardingInput? {
        guard config.hasFeature(.twinning) else { return nil }


        return OnboardingInput(
            steps: .twins(TwinsOnboardingStep.twinningSteps),
            cardInput: .cardModel(self),
            welcomeStep: nil,
            twinData: cardInfo.walletData.twinData,
            currentStepIndex: 0,
            isStandalone: true)
    }


    var isResetToFactoryAvailable: Bool {
        config.hasFeature(.resetToFactory)
    }

    var isSuccesfullyLoaded: Bool {
        walletModels.allConforms { $0.state.isSuccesfullyLoaded }
    }

    var hasBalance: Bool {
        walletModels.contains { $0.hasBalance }
    }

    var shoulShowLegacyDerivationAlert: Bool {
        config.warningEvents.contains(where: { $0 == .legacyDerivation })
    }

    var canExchangeCrypto: Bool { config.hasFeature(.exchange) }

    var cachedImage: UIImage? = nil

    var userWallet: UserWallet? {
        userWalletModel?.userWallet
    }

//    var isUserWalletLocked: Bool {
//        return userWallet?.isLocked ?? false
//    }

    var subtitle: String {
        if let embeddedBlockchain = config.embeddedBlockchain {
            return embeddedBlockchain.blockchainNetwork.blockchain.displayName
        }

        let count = config.cardsCount
        switch count {
        case 1:
            return "\(count) Card"
        default:
            return "\(count) Cards"
        }
    }

    private var searchBlockchainsCancellable: AnyCancellable? = nil
    private var bag = Set<AnyCancellable>()

    convenience init(userWallet: UserWallet) {
        self.init(cardInfo: userWallet.cardInfo(), userWallet: userWallet)
    }

    init(cardInfo: CardInfo, userWallet: UserWallet? = nil) {
        self.cardInfo = cardInfo
        self.config = UserWalletConfigFactory(cardInfo).makeConfig()

        createUserWalletModelIfNeeded(userWallet)
        updateCardPinSettings()
        updateCurrentSecurityOption()
        bind()
    }

    func setupWarnings() {
        warningsService.setupWarnings(for: config)
    }

    func appendDefaultBlockchains() {
        add(entries: config.defaultBlockchains) { _ in }
    }

    func deriveEntriesWithoutDerivation() {
        guard let userWalletModel = userWalletModel else {
            assertionFailure("UserWalletModel not created")
            return
        }

        let derivationManager = DerivationManager(config: config, cardInfo: cardInfo)
        derivationManager.deriveIfNeeded(
            entries: userWalletModel.getEntriesWithoutDerivation()
        ) { [weak self] result in
            switch result {
            case let .success(card):
                if let card = card {
                    self?.update(with: CardDTO(card: card))
                }
                self?.userWalletModel?.updateAndReloadWalletModels()
            case .failure:
                print("Derivation error")
            }
        }
    }

    // MARK: - Security

    func changeSecurityOption(_ option: SecurityModeOption, completion: @escaping (Result<Void, Error>) -> Void) {
        switch option {
        case .accessCode:
            tangemSdk.startSession(with: SetUserCodeCommand(accessCode: nil),
                                   cardId: cardId,
                                   initialMessage: Message(header: nil, body: "initial_message_change_access_code_body".localized)) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.cardPinSettings.isPin1Default = false
                    self.cardPinSettings.isPin2Default = true
                    self.updateCurrentSecurityOption()
                    completion(.success(()))
                case .failure(let error):
                    Analytics.logCardSdkError(error, for: .changeSecOptions, card: self.cardInfo.card, parameters: [.newSecOption: "Access Code"])
                    completion(.failure(error))
                }
            }
        case .longTap:
            tangemSdk.startSession(with: SetUserCodeCommand.resetUserCodes,
                                   cardId: cardId) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.cardPinSettings.isPin1Default = true
                    self.cardPinSettings.isPin2Default = true
                    self.updateCurrentSecurityOption()
                    completion(.success(()))
                case .failure(let error):
                    Analytics.logCardSdkError(error, for: .changeSecOptions, card: self.cardInfo.card, parameters: [.newSecOption: "Long tap"])
                    completion(.failure(error))
                }
            }
        case .passCode:
            tangemSdk.startSession(with: SetUserCodeCommand(passcode: nil),
                                   cardId: cardId,
                                   initialMessage: Message(header: nil, body: "initial_message_change_passcode_body".localized)) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.cardPinSettings.isPin1Default = true
                    self.cardPinSettings.isPin2Default = false
                    self.updateCurrentSecurityOption()
                    completion(.success(()))
                case .failure(let error):
                    Analytics.logCardSdkError(error, for: .changeSecOptions, card: self.cardInfo.card, parameters: [.newSecOption: "Pass code"])
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Wallet

    func createWallet(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let card = self.cardInfo.card
        tangemSdk.startSession(with: CreateWalletAndReadTask(with: config.defaultCurve),
                               cardId: cardId,
                               initialMessage: Message(header: nil,
                                                       body: "initial_message_create_wallet_body".localized)) { [weak self] result in
            switch result {
            case .success(let card):
                self?.update(with: CardDTO(card: card))
                completion(.success(()))
            case .failure(let error):
                Analytics.logCardSdkError(error, for: .createWallet, card: card)
                completion(.failure(error))
            }
        }
    }

    func resetToFactory(completion: @escaping (Result<UserTokenList, Error>) -> Void) {
        let card = self.cardInfo.card
        tangemSdk.startSession(with: ResetToFactorySettingsTask(),
                               cardId: cardId,
                               initialMessage: Message(header: nil,
                                                       body: "initial_message_purge_wallet_body".localized)) { [weak self] result in
            switch result {
            case .success:
                Analytics.log(.factoryResetSuccess)
                self?.userWalletModel?.clearRepository(result: completion)
                self?.clearTwinPairKey()
            case .failure(let error):
                Analytics.logCardSdkError(error, for: .purgeWallet, card: card)
                completion(.failure(error))
            }
        }
    }

    func getBlockchainNetwork(for blockchain: Blockchain, derivationPath: DerivationPath?) -> BlockchainNetwork {
        let derivationPath = derivationPath ?? blockchain.derivationPath(for: cardInfo.card.derivationStyle)
        return BlockchainNetwork(blockchain, derivationPath: derivationPath)
    }

    func setUserWallet(_ userWallet: UserWallet) {
        cardInfo = userWallet.cardInfo()
        userWalletModel?.setUserWallet(userWallet)
    }

    // MARK: - Update

    func update(with card: CardDTO) {
        print("🔄 Updating CardViewModel with new Card")
        let oldKeys = cardInfo.card.wallets.map { $0.derivedKeys }
        let newKeys = card.wallets.map { $0.derivedKeys }
        print("🔄 Updating Config with update derivationKeys \n",
              "oldKeys: \(oldKeys.map { $0.keys.map { $0.rawPath }})\n",
              "newKeys: \(newKeys.map { $0.keys.map { $0.rawPath }})")

        cardInfo.card = card // TODO: We need to update only changed parts of card
        config = UserWalletConfigFactory(cardInfo).makeConfig()

        updateModel()
        updateUserWallet()
    }

    func update(with cardInfo: CardInfo) {
        print("🔄 Updating Card view model with new CardInfo")
        self.cardInfo = cardInfo
        updateModel()
        updateUserWallet()
    }

    func clearTwinPairKey() { // TODO: refactor and remove
        if case let .twin(walletData, twinData) = cardInfo.walletData {
            let newData = TwinData(series: twinData.series)
            cardInfo.walletData = .twin(walletData, newData)
        }
    }

    func logSdkError(_ error: Error, action: Analytics.Action, parameters: [Analytics.ParameterKey: Any] = [:]) {
        Analytics.logCardSdkError(error.toTangemSdkError(), for: action, card: cardInfo.card, parameters: parameters)
    }

    func didScan() {
        Analytics.logScan(card: cardInfo.card, config: config)
        onAppear()
    }

    func onAppear() {
        updateConfig()
    }

    func getDisabledLocalizedReason(for feature: UserWalletFeature) -> String? {
        config.getFeatureAvailability(feature).disabledLocalizedReason
    }

    private func updateConfig() {
        var config = config.sdkConfig
        if AppSettings.shared.saveAccessCodes {
            var hasCode = false
            if card.isAccessCodeSet {
                hasCode = true
            }
            if let isPasscodeSet = card.isPasscodeSet, isPasscodeSet {
                hasCode = true
            }
            if hasCode {
                config.accessCodeRequestPolicy = .alwaysWithBiometrics
            }
        }

        tangemSdkProvider.setup(with: config)
    }

    private func updateModel() {
        print("🔄 Updating Card view model")
        updateCardPinSettings()
        updateCurrentSecurityOption()

        warningsService.setupWarnings(for: config)
        createUserWalletModelIfNeeded()
        userWalletModel?.updateUserWalletModel(with: config)
    }

    private func searchBlockchains() {
        guard config.hasFeature(.tokensSearch) else { return }

        searchBlockchainsCancellable = nil

        let currentBlockhains = wallets.map { $0.blockchain }
        let unused: [StorageEntry] = config.supportedBlockchains
            .subtracting(currentBlockhains)
            .map { StorageEntry(blockchainNetwork: .init($0, derivationPath: nil), tokens: []) }

        let models = unused.compactMap {
            try? config.makeWalletModel(for: $0)
        }

        if models.isEmpty {
            return
        }

        searchBlockchainsCancellable = Publishers.MergeMany(models.map { $0.update() })
            .collect()
            .receiveCompletion { [weak self] _ in
                guard let self = self else { return }

                let notEmptyWallets = models.filter { !$0.wallet.isEmpty }
                if !notEmptyWallets.isEmpty {
                    let entries = notEmptyWallets.map {
                        StorageEntry(blockchainNetwork: $0.blockchainNetwork, tokens: [])
                    }

                    // TODO: Check it
                    self.add(entries: entries) { _ in }
                }
            }
    }

    private func searchTokens() {
        guard config.hasFeature(.tokensSearch),
              !AppSettings.shared.searchedCards.contains(cardId) else {
            return
        }

        guard let ethBlockchain = config.supportedBlockchains.first(where: {
            if case .ethereum = $0 {
                return true
            }

            return false
        }) else {
            return
        }

        var shouldAddWalletManager = false
        let network = getBlockchainNetwork(for: ethBlockchain, derivationPath: nil)
        var ethWalletModel = walletModels.first(where: { $0.blockchainNetwork == network })

        if ethWalletModel == nil {
            shouldAddWalletManager = true
            let entry = StorageEntry(blockchainNetwork: network, tokens: [])
            ethWalletModel = try? config.makeWalletModel(for: entry)
        }

        guard let ethWalletModel = ethWalletModel,
              let tokenFinder = ethWalletModel.walletManager as? TokenFinder else {
            AppSettings.shared.searchedCards.append(self.cardId)
            self.searchBlockchains()
            return
        }

        tokenFinder.findErc20Tokens(knownTokens: []) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let tokensAdded):
                if tokensAdded, shouldAddWalletManager {
                    let tokens = ethWalletModel.walletManager.cardTokens
                    let entry = StorageEntry(blockchainNetwork: network, tokens: tokens)
                    // TODO: Check it
                    self.add(entries: [entry]) { _ in }
                }
            case .failure(let error):
                print(error)
            }

            AppSettings.shared.searchedCards.append(self.cardId)
            self.searchBlockchains()
        }
    }

    private func updateCardPinSettings() {
        cardPinSettings.isPin1Default = !cardInfo.card.isAccessCodeSet
        cardInfo.card.isPasscodeSet.map { self.cardPinSettings.isPin2Default = !$0 }
    }

    private func updateCurrentSecurityOption() {
        if !(cardPinSettings.isPin1Default ?? true) {
            self.currentSecurityOption = .accessCode
        } else if !(cardPinSettings.isPin2Default ?? true) {
            self.currentSecurityOption = .passCode
        } else {
            self.currentSecurityOption = .longTap
        }
    }

    private func bind() {
        signer.signPublisher.sink { [unowned self] card in
            self.update(with: CardDTO(card: card))
            // TODO: Save user wallet
            self.updateUserWallet()
        }
        .store(in: &bag)
    }

    private func updateUserWallet() {
        let userWallet = UserWalletFactory().userWallet(from: self)

        userWalletModel?.setUserWallet(userWallet)

        if userWalletListService.contains(userWallet) {
            let _ = userWalletListService.save(userWallet)
        }
    }

    private func createUserWalletModelIfNeeded(_ userWallet: UserWallet? = nil) {
        guard userWalletModel == nil, cardInfo.card.hasWallets else { return }

        // TODO: Move it to where will be configure module
        let userTokenListManager = CommonUserTokenListManager(config: config, userWalletId: cardInfo.card.userWalletId)
        let walletListManager = CommonWalletListManager(
            config: config,
            userTokenListManager: userTokenListManager
        )

        userWalletModel = CommonUserWalletModel(
            userTokenListManager: userTokenListManager,
            walletListManager: walletListManager,
            userWallet: userWallet!
        )
    }
}

// MARK: - Proxy for User Wallet Model

extension CardViewModel {
    func subscribeWalletModels() -> AnyPublisher<[WalletModel], Never> {
        guard let userWalletModel = userWalletModel else {
            assertionFailure("UserWalletModel not created")
            return Just([]).eraseToAnyPublisher()
        }

        return userWalletModel.subscribeToWalletModels()
    }

    func subscribeToEntriesWithoutDerivation() -> AnyPublisher<[StorageEntry], Never> {
        guard let userWalletModel = userWalletModel else {
            assertionFailure("UserWalletModel not created")
            return Just([]).eraseToAnyPublisher()
        }

        return userWalletModel.subscribeToEntriesWithoutDerivation()
    }

    func add(entries: [StorageEntry], completion: @escaping (Result<UserTokenList, Error>) -> Void) {
        let derivationManager = DerivationManager(config: config, cardInfo: cardInfo)
        derivationManager.deriveIfNeeded(entries: entries) { [weak self] result in
            switch result {
            case let .success(card):
                if let card = card {
                    self?.update(with: CardDTO(card: card))
                }

                self?.userWalletModel?.append(entries: entries, result: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func update(entries: [StorageEntry], completion: @escaping (Result<UserTokenList, Error>) -> Void) {
        let derivationManager = DerivationManager(config: config, cardInfo: cardInfo)
        derivationManager.deriveIfNeeded(entries: entries, completion: { [weak self] result in
            switch result {
            case let .success(card):
                if let card = card {
                    self?.update(with: CardDTO(card: card))
                }

                self?.userWalletModel?.update(entries: entries, result: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func canManage(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool {
        guard let userWalletModel = userWalletModel else {
            assertionFailure("UserWalletModel not created")
            return false
        }

        return userWalletModel.canManage(amountType: amountType, blockchainNetwork: blockchainNetwork)
    }

    func remove(item: CommonUserWalletModel.RemoveItem, result: @escaping (Result<UserTokenList, Error>) -> Void) {
        guard let userWalletModel = userWalletModel else {
            assertionFailure("UserWalletModel not created")
            return
        }

        userWalletModel.remove(item: item, result: result)
    }
}

extension CardViewModel {
    enum WalletsBalanceState {
        case inProgress
        case loaded
    }
}
