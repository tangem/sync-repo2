//
//  UserWalletListViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 29.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class UserWalletListViewModel: ObservableObject {
    // MARK: - ViewState
    @Published var selectedUserWalletId: Data?
    @Published var multiCurrencyModels: [CardViewModel] = []
    @Published var singleCurrencyModels: [CardViewModel] = []
    @Published var isScanningCard = false
    @Published var error: AlertBinder?
    @Published var showTroubleshootingView: Bool = false

    // MARK: - Dependencies

    @Injected(\.cardsRepository) private var cardsRepository: CardsRepository
    @Injected(\.userWalletListService) private var userWalletListService: UserWalletListService
    @Injected(\.failedScanTracker) var failedCardScanTracker: FailedScanTrackable

    var bottomSheetHeightUpdateCallback: ((ResizeSheetAction) -> ())?

    private unowned let coordinator: UserWalletListRoutable
    private var bag: Set<AnyCancellable> = []
    private var initialized = false

    init(
        coordinator: UserWalletListRoutable
    ) {
        self.coordinator = coordinator
        updateModels()
    }

    func onAppear() {
        if !initialized {
            initialized = true

            for model in (multiCurrencyModels + singleCurrencyModels) {
                model.getCardInfo()
                model.updateState()
            }

            selectedUserWalletId = userWalletListService.selectedUserWalletId
        }
    }

    func updateModels() {
        multiCurrencyModels = userWalletListService.models.filter { $0.isMultiWallet }
        singleCurrencyModels = userWalletListService.models.filter { !$0.isMultiWallet }
    }

    func onUserWalletTapped(_ userWallet: UserWallet) {
        setSelectedWallet(userWallet)
    }

    func addCard() {
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
                self?.processScannedCard(cardModel)
            }
            .store(in: &bag)
    }

    func tryAgain() {
        Analytics.log(.tryAgainTapped)
        addCard()
    }

    func requestSupport() {
        Analytics.log(.supportTapped)
        failedCardScanTracker.resetCounter()
        coordinator.openMail(with: failedCardScanTracker)
    }

    func editWallet(_ userWallet: UserWallet) {
        let vc: UIAlertController = UIAlertController(title: "Rename Wallet", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "common_cancel".localized, style: .cancel) { _ in

        }
        vc.addAction(cancelAction)

        var nameTextField: UITextField?
        vc.addTextField { textField in
            nameTextField = textField
            #warning("l10n")
            nameTextField?.placeholder = "Wallet name"
            nameTextField?.text = userWallet.name
            nameTextField?.clearButtonMode = .whileEditing
            nameTextField?.autocapitalizationType = .sentences
        }

        let acceptButton = UIAlertAction(title: "common_ok".localized, style: .default) { [weak self, nameTextField] _ in
            let name = nameTextField?.text ?? ""
            self?.userWalletListService.setName(userWallet, name: name)
            self?.updateModels()
        }
        vc.addAction(acceptButton)

        UIApplication.modalFromTop(vc)
    }

    func deleteUserWallet(_ userWallet: UserWallet) {
        let userWalletId = userWallet.userWalletId
        let models = userWalletListService.models

        let newSelectedUserWallet: UserWallet?

        if userWalletId == selectedUserWalletId,
           let deletedUserWalletIndex = models.firstIndex(where: { $0.userWallet.userWalletId == userWalletId })
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

        let oldModelSections = [multiCurrencyModels, singleCurrencyModels]

        userWalletListService.deleteWallet(userWallet)
        multiCurrencyModels.removeAll { $0.userWallet.userWalletId == userWallet.userWalletId }
        singleCurrencyModels.removeAll { $0.userWallet.userWalletId == userWallet.userWalletId }

        if let newSelectedUserWallet = newSelectedUserWallet {
            setSelectedWallet(newSelectedUserWallet)
        }

        if userWalletListService.isEmpty {
            AppSettings.shared.saveUserWallets = false
            coordinator.popToRoot()
        } else {
            updateHeight(oldModelSections: oldModelSections)
        }
    }

    private func processScannedCard(_ cardModel: CardViewModel) {
        let card = cardModel.card

        let userWallet = UserWallet(userWalletId: card.cardPublicKey, name: "", card: card, walletData: cardModel.walletData, artwork: nil, keys: cardModel.derivedKeys, isHDWalletAllowed: card.settings.isHDWalletAllowed)

        if userWalletListService.contains(userWallet) {
            return
        }

        let oldModelSections = [multiCurrencyModels, singleCurrencyModels]

        if userWalletListService.save(cardModel.userWallet) {
            let newModel = CardViewModel(userWallet: userWallet)
            if newModel.isMultiWallet {
                multiCurrencyModels.append(newModel)
            } else {
                singleCurrencyModels.append(newModel)
            }
            newModel.getCardInfo()
            newModel.updateState()

            setSelectedWallet(userWallet)

            updateHeight(oldModelSections: oldModelSections)
        }
    }

    private func setSelectedWallet(_ userWallet: UserWallet) {
        guard selectedUserWalletId != userWallet.userWalletId else {
            return
        }

        userWalletListService.unlockWithCard(userWallet) { [weak self] result in
            guard case .success = result else {
                return
            }

            guard let selectedModel = self?.userWalletListService.models.first(where: { $0.userWallet.userWalletId == userWallet.userWalletId }) else {
                return
            }

            let userWallet = selectedModel.userWallet

            selectedModel.getCardInfo()
            selectedModel.updateState()

            self?.updateModels()

            self?.selectedUserWalletId = userWallet.userWalletId
            self?.userWalletListService.selectedUserWalletId = userWallet.userWalletId
            self?.coordinator.didTapUserWallet(userWallet: userWallet)
        }
    }

    private func updateHeight(oldModelSections: [[CardViewModel]]) {
        let newModelSections = [multiCurrencyModels, singleCurrencyModels]

        let cellHeight = 67
        let headerHeight = 37

        let oldNumberOfModels = oldModelSections.reduce(into: 0) { $0 += $1.count }
        let newNumberOfModels = newModelSections.reduce(into: 0) { $0 += $1.count }

        let oldNumberOfSections = oldModelSections.filter { !$0.isEmpty }.count
        let newNumberOfSections = newModelSections.filter { !$0.isEmpty }.count

        let heightDifference = cellHeight * (newNumberOfModels - oldNumberOfModels) + headerHeight * (newNumberOfSections - oldNumberOfSections)

        bottomSheetHeightUpdateCallback?(.changeHeight(byValue: Double(heightDifference)))
    }
}
