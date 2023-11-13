//
//  MainViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI

final class MainViewModel: ObservableObject {
    @Injected(\.userWalletRepository) private var userWalletRepository: UserWalletRepository
    @InjectedWritable(\.mainBottomSheetVisibility) private var bottomSheetVisibility: MainBottomSheetVisibility

    // MARK: - ViewState

    @Published var pages: [MainUserWalletPageBuilder] = []
    @Published var selectedCardIndex = 0
    @Published var isHorizontalScrollDisabled = false
    @Published var showAddressCopiedToast = false
    @Published var actionSheet: ActionSheetBinder?

    @Published var unlockWalletBottomSheetViewModel: UnlockUserWalletBottomSheetViewModel?

    let swipeDiscoveryAnimationTrigger = CardsInfoPagerSwipeDiscoveryAnimationTrigger()

    var isMainBottomSheetEnabled: Bool { FeatureProvider.isAvailable(.mainScreenBottomSheet) }

    // MARK: - Dependencies

    private let mainUserWalletPageBuilderFactory: MainUserWalletPageBuilderFactory
    private let swipeDiscoveryHelper: WalletSwipeDiscoveryHelper
    private weak var coordinator: MainRoutable?

    // MARK: - Internal state

    private var userWalletIdsWithInsertedUserWalletModels: Set<Data> = []
    private var pendingUserWalletModelsToAdd: [UserWalletModel] = []

    private var isLoggingOut = false

    private var bag = Set<AnyCancellable>()

    // MARK: - Initializers

    init(
        coordinator: MainRoutable,
        swipeDiscoveryHelper: WalletSwipeDiscoveryHelper,
        mainUserWalletPageBuilderFactory: MainUserWalletPageBuilderFactory
    ) {
        self.coordinator = coordinator
        self.swipeDiscoveryHelper = swipeDiscoveryHelper
        self.mainUserWalletPageBuilderFactory = mainUserWalletPageBuilderFactory

        pages = mainUserWalletPageBuilderFactory.createPages(
            from: userWalletRepository.models,
            lockedUserWalletDelegate: self,
            mainViewDelegate: self,
            multiWalletContentDelegate: self
        )
        bind()
    }

    convenience init(
        selectedUserWalletId: UserWalletId,
        coordinator: MainRoutable,
        swipeDiscoveryHelper: WalletSwipeDiscoveryHelper,
        mainUserWalletPageBuilderFactory: MainUserWalletPageBuilderFactory
    ) {
        self.init(
            coordinator: coordinator,
            swipeDiscoveryHelper: swipeDiscoveryHelper,
            mainUserWalletPageBuilderFactory: mainUserWalletPageBuilderFactory
        )

        if let selectedIndex = pages.firstIndex(where: { $0.id == selectedUserWalletId }) {
            selectedCardIndex = selectedIndex
        }
    }

    // MARK: - Internal functions

    func openDetails() {
        let userWalletModel = userWalletRepository.models[selectedCardIndex]

        if userWalletModel.isUserWalletLocked {
            openUnlockUserWalletBottomSheet(for: userWalletModel)
            return
        }

        coordinator?.openDetails(for: userWalletModel)
    }

    func onViewAppear() {
        Analytics.log(.mainScreenOpened)

        bottomSheetVisibility.show()

        addPendingUserWalletModelsIfNeeded { [weak self] in
            self?.swipeDiscoveryHelper.scheduleSwipeDiscoveryIfNeeded()
        }
    }

    func onViewDisappear() {
        bottomSheetVisibility.hide()
        swipeDiscoveryHelper.cancelScheduledSwipeDiscovery()
    }

    func onPullToRefresh(completionHandler: @escaping RefreshCompletionHandler) {
        Analytics.log(.mainRefreshed)

        isHorizontalScrollDisabled = true
        let completion = { [weak self] in
            self?.isHorizontalScrollDisabled = false
            completionHandler()
        }
        let page = pages[selectedCardIndex]

        switch page {
        case .singleWallet(_, _, let viewModel):
            viewModel.onPullToRefresh(completionHandler: completion)
        case .multiWallet(_, _, let viewModel):
            viewModel.onPullToRefresh(completionHandler: completion)
        case .lockedWallet:
            completion()
        }
    }

    func onPageChange(dueTo reason: CardsInfoPageChangeReason) {
        guard reason == .byGesture else { return }

        Analytics.log(.mainScreenWalletChangedBySwipe)

        if !AppSettings.shared.userDidSwipeWalletsOnMainScreen {
            AppSettings.shared.userDidSwipeWalletsOnMainScreen = true
        }
    }

    func updateIsBackupAllowed() {
        // TODO: Will be added in IOS-4165
    }

    func didTapEditWallet() {
        Analytics.log(.buttonEditWalletTapped)

        guard let userWallet = userWalletRepository.selectedModel?.userWallet else { return }

        let alert = AlertBuilder.makeAlertControllerWithTextField(
            title: Localization.userWalletListRenamePopupTitle,
            fieldPlaceholder: Localization.userWalletListRenamePopupPlaceholder,
            fieldText: userWallet.name
        ) { [weak self] newName in
            guard userWallet.name != newName else { return }

            var newUserWallet = userWallet
            newUserWallet.name = newName

            self?.userWalletRepository.save(newUserWallet)
        }

        AppPresenter.shared.show(alert)
    }

    func didTapDeleteWallet() {
        Analytics.log(.buttonDeleteWalletTapped)

        let sheet = ActionSheet(
            title: Text(Localization.userWalletListDeletePrompt),
            buttons: [
                .destructive(Text(Localization.commonDelete), action: weakify(self, forFunction: MainViewModel.didConfirmWalletDeletion)),
                .cancel(Text(Localization.commonCancel)),
            ]
        )
        actionSheet = ActionSheetBinder(sheet: sheet)
    }

    func didConfirmWalletDeletion() {
        guard
            let userWalletId = userWalletRepository.selectedUserWalletId,
            let userWalletModel = userWalletRepository.models.first(where: { $0.userWalletId.value == userWalletId })
        else {
            return
        }

        userWalletRepository.delete(userWalletModel.userWalletId, logoutIfNeeded: true)
    }

    // TODO: Andrey Fedorov - Do we need such sophisticated logic at all?
    private func processUpdatedUserWalletModel(_ userWalletModel: UserWalletModel) {
        if userWalletIdsWithInsertedUserWalletModels.contains(userWalletModel.userWallet.userWalletId) {
            pendingUserWalletModelsToAdd.append(userWalletModel)
        } else {
            addNewPage(for: userWalletModel)
        }
    }

    private func addPendingUserWalletModelsIfNeeded(completion: @escaping () -> Void) {
        if pendingUserWalletModelsToAdd.isEmpty {
            completion()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.addPendingUserWalletModelsDelay) { [weak self] in
                defer { completion() }

                guard let self = self else { return }

                let userWalletModels = pendingUserWalletModelsToAdd
                pendingUserWalletModelsToAdd.removeAll()

                var processedUserWalletIds: Set<Data> = []
                for userWalletModel in userWalletModels {
                    processedUserWalletIds.insert(userWalletModel.userWallet.userWalletId)
                    addNewPage(for: userWalletModel)
                }
                userWalletIdsWithInsertedUserWalletModels.subtract(processedUserWalletIds)
            }
        }
    }

    private func addNewPage(for userWalletModel: UserWalletModel) {
        // FIXME: Awaiting CommonUserWalletRepository event system refactoring
        // We need this check to prevent adding new pages after each
        // UserWalletModel update in `CommonUserWalletRepository`.
        // The problem itself not in `update` event from repository but
        // in `inserted` event, which is sending `UserWallet` instead of `UserWalletModel`
        if pages.contains(where: { $0.id == userWalletModel.userWalletId }) {
            return
        }

        guard
            let newPage = mainUserWalletPageBuilderFactory.createPage(
                for: userWalletModel,
                lockedUserWalletDelegate: self,
                mainViewDelegate: self,
                multiWalletContentDelegate: self
            )
        else {
            return
        }

        let newPageIndex = pages.count
        pages.append(newPage)
        selectedCardIndex = newPageIndex
    }

    private func removePages(with userWalletIds: [Data]) {
        pages.removeAll { page in
            userWalletIds.contains(page.id.value)
        }

        guard
            let newSelectedId = userWalletRepository.selectedUserWalletId,
            let index = pages.firstIndex(where: { $0.id.value == newSelectedId })
        else {
            return
        }

        selectedCardIndex = index
    }

    private func recreatePages() {
        pages = mainUserWalletPageBuilderFactory.createPages(
            from: userWalletRepository.models,
            lockedUserWalletDelegate: self,
            mainViewDelegate: self,
            multiWalletContentDelegate: self
        )
    }

    // MARK: - Private functions

    private func bind() {
        $selectedCardIndex
            .dropFirst()
            .sink { [weak self] newIndex in
                guard let userWalletId = self?.pages[newIndex].id else {
                    return
                }

                Analytics.log(.walletOpened)
                self?.userWalletRepository.setSelectedUserWalletId(
                    userWalletId.value,
                    unlockIfNeeded: false,
                    reason: .userSelected
                )
            }
            .store(in: &bag)

        userWalletRepository.eventProvider
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .locked:
                    isLoggingOut = true
                case .scan:
                    // TODO: Do we need to place spinner into Navbar?..
                    break
                case .inserted(let userWallet):
                    userWalletIdsWithInsertedUserWalletModels.insert(userWallet.userWalletId)
                case .updated(let userWalletModel):
                    processUpdatedUserWalletModel(userWalletModel)
                case .deleted(let userWalletIds):
                    // This model is alive for enough time to receive the "deleted" event
                    // after the last model has been removed and the application has been logged out
                    if isLoggingOut == true {
                        return
                    }
                    removePages(with: userWalletIds)
                    swipeDiscoveryHelper.reset()
                case .selected:
                    // TODO: Andrey Fedorov - Do we need to handle this case?
                    break
                case .replaced:
                    recreatePages()
                }
            }
            .store(in: &bag)
    }

    private func log(_ message: String) {
        AppLog.shared.debug("[Main V2] \(message)")
    }
}

// MARK: - Navigation

extension MainViewModel: MainLockedUserWalletDelegate {
    func openUnlockUserWalletBottomSheet(for userWalletModel: UserWalletModel) {
        unlockWalletBottomSheetViewModel = .init(
            userWalletModel: userWalletModel,
            delegate: self
        )
    }
}

extension MainViewModel: UnlockUserWalletBottomSheetDelegate {
    func unlockedWithBiometry() {
        unlockWalletBottomSheetViewModel = nil
        recreatePages()
    }

    func userWalletUnlocked(_ userWalletModel: UserWalletModel) {
        guard
            let index = pages.firstIndex(where: { $0.id == userWalletModel.userWalletId }),
            let page = mainUserWalletPageBuilderFactory.createPage(
                for: userWalletModel,
                lockedUserWalletDelegate: self,
                mainViewDelegate: self,
                multiWalletContentDelegate: self
            )
        else {
            return
        }

        pages[index] = page
        unlockWalletBottomSheetViewModel = nil
    }

    func openMail(with dataCollector: EmailDataCollector, recipient: String, emailType: EmailType) {
        unlockWalletBottomSheetViewModel = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.coordinator?.openMail(with: dataCollector, emailType: emailType, recipient: recipient)
        }
    }
}

extension MainViewModel: MultiWalletContentDelegate {
    func displayAddressCopiedToast() {
        showAddressCopiedToast = true
    }
}

extension MainViewModel: MainViewDelegate {
    func present(actionSheet: ActionSheetBinder) {
        self.actionSheet = actionSheet
    }
}

// MARK: - WalletSwipeDiscoveryHelperDelegate protocol conformance

extension MainViewModel: WalletSwipeDiscoveryHelperDelegate {
    func numberOfWallets(_ discoveryHelper: WalletSwipeDiscoveryHelper) -> Int {
        return pages.count
    }

    func userDidSwipeWallets(_ discoveryHelper: WalletSwipeDiscoveryHelper) -> Bool {
        return AppSettings.shared.userDidSwipeWalletsOnMainScreen
    }

    func helperDidTriggerSwipeDiscoveryAnimation(_ discoveryHelper: WalletSwipeDiscoveryHelper) {
        swipeDiscoveryAnimationTrigger.triggerDiscoveryAnimation()
    }
}

// MARK: - Constants

private extension MainViewModel {
    private enum Constants {
        /// A small delay for animated addition of newly inserted wallet(s) after the main view becomes visible.
        static let addPendingUserWalletModelsDelay = 1.0
    }
}
