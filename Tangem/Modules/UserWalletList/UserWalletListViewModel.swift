//
//  UserWalletListViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 29.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class UserWalletListViewModel: ObservableObject, Identifiable {
    // MARK: - ViewState
    @Published var selectedUserWalletId: Data?
    @Published var multiCurrencyModels: [UserWalletListCellViewModel] = []
    @Published var singleCurrencyModels: [UserWalletListCellViewModel] = []
    @Published var isScanningCard = false
    @Published var error: AlertBinder?
    @Published var showTroubleshootingView: Bool = false
    @Published var showingDeleteConfirmation: Bool = false

    // MARK: - Dependencies

    @Injected(\.cardsRepository) private var cardsRepository: CardsRepository
    @Injected(\.userWalletListService) private var userWalletListService: UserWalletListService
    @Injected(\.failedScanTracker) var failedCardScanTracker: FailedScanTrackable

    var unlockAllButtonLocalizationKey: LocalizedStringKey {
        switch BiometricAuthorizationUtils.biometryType {
        case .faceID:
            return "user_wallet_list_unlock_all_face_id"
        case .touchID:
            return "user_wallet_list_unlock_all_touch_id"
        case .none:
            return ""
        @unknown default:
            return ""
        }
    }

    var isUnlocked: Bool {
        userWalletListService.isUnlocked
    }

    private unowned let coordinator: UserWalletListRoutable
    private var bag: Set<AnyCancellable> = []
    private var initialized = false
    private var userWalletIdToBeDeleted: Data?

    init(
        coordinator: UserWalletListRoutable
    ) {
        self.coordinator = coordinator
        selectedUserWalletId = userWalletListService.selectedUserWalletId
        updateModels()
    }

    func onAppear() {
        if !initialized {
            initialized = true

            for model in (multiCurrencyModels + singleCurrencyModels) {
                model.updateTotalBalance()
                model.loadImage()
            }
        }
    }

    func updateModels() {
        multiCurrencyModels = userWalletListService.models
            .filter { $0.isMultiWallet }
            .compactMap { $0.userWalletModel }
            .map(mapToUserWalletListCellViewModel(userWalletModel:))

        singleCurrencyModels = userWalletListService.models
            .filter { !$0.isMultiWallet }
            .compactMap { $0.userWalletModel }
            .map(mapToUserWalletListCellViewModel(userWalletModel:))
    }

    func unlockAllWallets() {
        userWalletListService.unlockWithBiometry { [weak self] result in
            guard case .success = result else { return }
            self?.updateModels()
        }
    }

    func addUserWallet() {
        scanCardInternal { [weak self] cardModel in
            self?.processScannedCard(cardModel)
        }
    }

    func tryAgain() {
        Analytics.log(.tryAgainTapped)
        addUserWallet()
    }

    func requestSupport() {
        Analytics.log(.supportTapped)
        failedCardScanTracker.resetCounter()

        coordinator.dismissUserWalletList()

        let dismissingDelay = 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissingDelay) {
            self.coordinator.openMail(with: self.failedCardScanTracker, emailType: .failedToScanCard, recipient: EmailConfig.default.recipient)
        }
    }

    func editUserWallet(_ viewModel: UserWalletListCellViewModel) {
        let alert = UIAlertController(title: "user_wallet_list_rename_popup_title".localized, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "common_cancel".localized, style: .cancel) { _ in }
        alert.addAction(cancelAction)

        var nameTextField: UITextField?
        alert.addTextField { textField in
            nameTextField = textField
            nameTextField?.placeholder = "user_wallet_list_rename_popup_placeholder".localized
            nameTextField?.text = viewModel.userWallet.name
            nameTextField?.clearButtonMode = .whileEditing
            nameTextField?.autocapitalizationType = .sentences
        }

        let acceptButton = UIAlertAction(title: "common_ok".localized, style: .default) { [weak self, nameTextField] _ in
            var newUserWallet = viewModel.userWallet
            newUserWallet.name = nameTextField?.text ?? ""

            let _ = self?.userWalletListService.save(newUserWallet)
            self?.updateModels()
        }
        alert.addAction(acceptButton)

        UIApplication.modalFromTop(alert)
    }

    func showDeletionConfirmation(_ viewModel: UserWalletListCellViewModel) {
        showingDeleteConfirmation = true
        userWalletIdToBeDeleted = viewModel.userWalletId
    }

    func didCancelWalletDeletion() {
        userWalletIdToBeDeleted = nil
    }

    func didConfirmWalletDeletion() {
        let models = userWalletListService.models

        let viewModels = (multiCurrencyModels + singleCurrencyModels)
        guard let viewModel = viewModels.first(where: { $0.userWalletId == userWalletIdToBeDeleted }) else {
            return
        }

        let newSelectedUserWallet: UserWallet?

        if viewModel.userWalletId == selectedUserWalletId,
           let deletedUserWalletIndex = models.firstIndex(where: { $0.userWallet?.userWalletId == viewModel.userWalletId })
        {
            if deletedUserWalletIndex != (models.count - 1) {
                newSelectedUserWallet = models[deletedUserWalletIndex + 1].userWallet
            } else if deletedUserWalletIndex != 0 {
                newSelectedUserWallet = models[deletedUserWalletIndex - 1].userWallet
            } else {
                newSelectedUserWallet = nil
            }
        } else {
            newSelectedUserWallet = nil
        }

        userWalletListService.delete(viewModel.userWallet)
        multiCurrencyModels.removeAll { $0.userWalletId == viewModel.userWalletId }
        singleCurrencyModels.removeAll { $0.userWalletId == viewModel.userWalletId }

        if let newSelectedUserWallet = newSelectedUserWallet {
            setSelectedWallet(newSelectedUserWallet)
        }

        if userWalletListService.isEmpty {
            AppSettings.shared.saveUserWallets = false
            coordinator.popToRoot()
        }
    }

    private func scanCardInternal(_ completion: @escaping (CardViewModel) -> Void) {
        isScanningCard = true

        cardsRepository.scanPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("Failed to scan card: \(error)")
                    self?.isScanningCard = false
                    self?.failedCardScanTracker.recordFailure()

                    if self?.failedCardScanTracker.shouldDisplayAlert ?? false {
                        self?.showTroubleshootingView = true
                    } else {
                        switch error.toTangemSdkError() {
                        case .unknownError, .cardVerificationFailed:
                            self?.error = error.alertBinder
                        default:
                            break
                        }
                    }
                }
            } receiveValue: { [weak self] cardModel in
                self?.isScanningCard = false
                self?.failedCardScanTracker.resetCounter()

                let onboardingInput = cardModel.onboardingInput
                if onboardingInput.steps.needOnboarding {
                    cardModel.userWalletModel?.updateAndReloadWalletModels()
                    self?.openOnboarding(with: onboardingInput)
                } else {
                    completion(cardModel)
                }
            }
            .store(in: &bag)
    }

    private func processScannedCard(_ cardModel: CardViewModel) {
        guard let userWallet = cardModel.userWallet else { return }

        if userWalletListService.contains(userWallet) {
            return
        }

        if userWalletListService.save(userWallet) {
            let newModel = CardViewModel(userWallet: userWallet)

            if let cellModel = newModel.userWalletModel.map(mapToUserWalletListCellViewModel(userWalletModel:)) {
                if newModel.isMultiWallet {
                    multiCurrencyModels.append(cellModel)
                } else {
                    singleCurrencyModels.append(cellModel)
                }

                cellModel.updateTotalBalance()
            }

            setSelectedWallet(userWallet)
        }
    }

    private func setSelectedWallet(_ userWallet: UserWallet) {
        guard selectedUserWalletId != nil && selectedUserWalletId != userWallet.userWalletId else {
            return
        }

        let completion: (UserWallet) -> Void = { [weak self] userWallet in
            self?.selectedUserWalletId = userWallet.userWalletId
            self?.userWalletListService.selectedUserWalletId = userWallet.userWalletId
            self?.coordinator.didTapUserWallet(userWallet: userWallet)
            self?.updateSelectedWalletModel()
        }

        if !userWallet.isLocked {
            completion(userWallet)
            return
        }

        scanCardInternal { [weak self] cardModel in
            guard let userWallet = cardModel.userWallet else { return }

            self?.userWalletListService.unlockWithCard(userWallet) { result in
                guard case .success = result else {
                    return
                }

                guard
                    let selectedModel = self?.userWalletListService.models.first(where: { $0.userWallet?.userWalletId == userWallet.userWalletId }),
                    let userWallet = selectedModel.userWallet
                else {
                    return
                }

                // TODO: Check it
//                selectedModel.getCardInfo()
//                selectedModel.userWalletModel?.updateAndReloadWalletModels(showProgressLoading: true)

                self?.updateModels()

                completion(userWallet)
            }
        }
    }

    private func updateSelectedWalletModel() {
        let models = multiCurrencyModels + singleCurrencyModels
        for model in models {
            model.isSelected = selectedUserWalletId == model.userWalletId
        }
    }

    private func openOnboarding(with input: OnboardingInput) {
        DispatchQueue.main.async {
            self.coordinator.openOnboarding(with: input)
        }
    }

    private func getNumberOfTokens(for userWallet: UserWallet) -> String? {
        let numberOfBlockchainsPerItem = 1
        let items = CommonTokenItemsRepository(key: userWallet.userWalletId.hexString).getItems()
        let numberOfTokens = items.reduce(0) { sum, walletModel in
            sum + numberOfBlockchainsPerItem + walletModel.tokens.count
        }

        if numberOfTokens == 0 {
            return nil
        }

        return String.localizedStringWithFormat("token_count".localized, numberOfTokens)
    }

    private func mapToUserWalletListCellViewModel(userWalletModel: UserWalletModel) -> UserWalletListCellViewModel {
        let userWallet = userWalletModel.userWallet
        let config = UserWalletConfigFactory(userWallet.cardInfo()).makeConfig()
        let subtitle: String = {
            if let embeddedBlockchain = config.embeddedBlockchain {
                return embeddedBlockchain.blockchainNetwork.blockchain.displayName
            }

            return String.localizedStringWithFormat("card_label_card_count".localized, config.cardsCount)
        }()

        return UserWalletListCellViewModel(
            userWallet: userWallet,
            subtitle: subtitle,
            numberOfTokens: getNumberOfTokens(for: userWallet),
            isUserWalletLocked: userWallet.isLocked,
            isSelected: selectedUserWalletId == userWallet.userWalletId,
            totalBalanceProvider: TotalBalanceProvider(userWalletModel: userWalletModel),
            cardImageProvider: CardImageProvider()
        ) { [weak self] in
            self?.setSelectedWallet(userWallet)
        }
    }
}
