//
//  OrganizeTokensViewModel.swift
//  Tangem
//
//  Created by Andrey Fedorov on 06.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import CombineExt
import SwiftUI
import struct BlockchainSdk.Token

final class OrganizeTokensViewModel: ObservableObject {
    /// Sentinel value for `item` of `IndexPath` representing a section.
    var sectionHeaderItemIndex: Int { .min }

    private(set) lazy var headerViewModel = OrganizeTokensHeaderViewModel()
    @Published private(set) var sections: [OrganizeTokensListSectionViewModel] = []

    private unowned let coordinator: OrganizeTokensRoutable

    @available(*, deprecated, message: "Get rid of using `UserTokenListManager` and `[StorageEntry]`")
    private let userTokenListManager: UserTokenListManager
    private let walletModelsManager: WalletModelsManager
    private let walletModelsAdapter: OrganizeWalletModelsAdapter<String>

    private var currentlyDraggedSectionIdentifier: UUID?
    private var currentlyDraggedSectionItems: [OrganizeTokensListItemViewModel] = []

    private var didPerformBind = false

    private var bag = Set<AnyCancellable>()

    init(
        coordinator: OrganizeTokensRoutable,
        userTokenListManager: UserTokenListManager,
        walletModelsManager: WalletModelsManager,
        walletModelsAdapter: OrganizeWalletModelsAdapter<String>
    ) {
        self.coordinator = coordinator
        self.userTokenListManager = userTokenListManager
        self.walletModelsManager = walletModelsManager
        self.walletModelsAdapter = walletModelsAdapter
    }

    func onViewAppear() {
        bindIfNeeded()
    }

    func onViewDisappear() {
        // TODO: Andrey Fedorov - Really needed?
    }

    func onCancelButtonTap() {
        coordinator.didTapCancelButton()
    }

    func onApplyButtonTap() {
        // TODO: Andrey Fedorov - Add actual implementation (IOS-3461)
    }

    private func bindIfNeeded() {
        if didPerformBind {
            return
        }

        // TODO: Andrey Fedorov - Subscribe to balance, unavailable network and other publishers
        walletModelsAdapter
            .organizedWalletModels(from: walletModelsManager.walletModelsPublisher)
            .combineLatest(userTokenListManager.userTokensPublisher) // TODO: Andrey Fedorov - Get rid of using `UserTokenListManager` and `[StorageEntry]`
            .map { walletModels, storageEntries in
                return []   // TODO: Andrey Fedorov - Fix mapping
            }
            .assign(to: \.sections, on: self, ownership: .weak)
            .store(in: &bag)

        didPerformBind = true
    }

    private static func map(
        walletModels: [WalletModel],
        storageEntries: [StorageEntry]
    ) -> [OrganizeTokensListSectionViewModel] {
        let walletModelsKeyedByIds = walletModels.keyedFirst(by: \.id)
        let blockchainNetworks = walletModels.map(\.blockchainNetwork).toSet()
        let tokenIconInfoBuilder = TokenIconInfoBuilder()

        let listItemViewModels = storageEntries
            .reduce(into: [OrganizeTokensListItemViewModel]()) { result, entry in
                if blockchainNetworks.contains(entry.blockchainNetwork) {
                    let items = entry
                        .walletModelIds
                        .compactMap { walletModelsKeyedByIds[$0] }
                        .map { map(walletModel: $0, using: tokenIconInfoBuilder) }
                    result += items
                } else {
                    result += map(storageEntry: entry, using: tokenIconInfoBuilder)
                }
            }

        return [OrganizeTokensListSectionViewModel(style: .invisible, items: listItemViewModels)]
    }

    private static func map(
        walletModel: WalletModel,
        using tokenIconInfoBuilder: TokenIconInfoBuilder
    ) -> OrganizeTokensListItemViewModel {
        let tokenIcon = tokenIconInfoBuilder.build(
            for: walletModel.amountType,
            in: walletModel.blockchainNetwork.blockchain
        )

        return OrganizeTokensListItemViewModel(
            tokenIcon: tokenIcon,
            balance: .noData,
            isDraggable: false,
            networkUnreachable: false,
            hasPendingTransactions: walletModel.hasPendingTx
        )
    }

    private static func map(
        storageEntry: StorageEntry,
        using tokenIconInfoBuilder: TokenIconInfoBuilder
    ) -> [OrganizeTokensListItemViewModel] {
        // TODO: Andrey Fedorov - How to fetch all details from `StorageEntry`?
        let tokenIcon = tokenIconInfoBuilder.build(
            for: .coin,
            in: storageEntry.blockchainNetwork.blockchain
        )
        let coinListItemViewModel = OrganizeTokensListItemViewModel(
            tokenIcon: tokenIcon,
            balance: .noData,
            isDraggable: false,
            networkUnreachable: false,
            hasPendingTransactions: false
        )
        let tokenListItemViewModels = storageEntry.tokens.map { token in
            let tokenIcon = tokenIconInfoBuilder.build(
                for: .token(value: token),
                in: storageEntry.blockchainNetwork.blockchain
            )
            return OrganizeTokensListItemViewModel(
                tokenIcon: tokenIcon,
                balance: .noData,
                isDraggable: false,
                networkUnreachable: false,
                hasPendingTransactions: false
            )
        }

        return [coinListItemViewModel] + tokenListItemViewModels
    }
}

// MARK: - Drag and drop support

extension OrganizeTokensViewModel {
    func itemViewModel(for identifier: UUID) -> OrganizeTokensListItemViewModel? {
        return sections
            .flatMap { $0.items }
            .first { $0.id == identifier }
    }

    func sectionViewModel(for identifier: UUID) -> OrganizeTokensListSectionViewModel? {
        return sections
            .first { $0.id == identifier }
    }

    func viewModelIdentifier(at indexPath: IndexPath) -> UUID? {
        return sectionViewModel(at: indexPath)?.id ?? itemViewModel(at: indexPath).id
    }

    func move(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.item == sectionHeaderItemIndex {
            assert(sourceIndexPath.item == destinationIndexPath.item, "Can't perform move operation between section and item or vice versa")
            let diff = sourceIndexPath.section > destinationIndexPath.section ? 0 : 1
            sections.move(
                fromOffsets: IndexSet(integer: sourceIndexPath.section),
                toOffset: destinationIndexPath.section + diff
            )
        } else {
            assert(sourceIndexPath.section == destinationIndexPath.section, "Can't perform move operation between section and item or vice versa")
            let diff = sourceIndexPath.item > destinationIndexPath.item ? 0 : 1
            sections[sourceIndexPath.section].items.move(
                fromOffsets: IndexSet(integer: sourceIndexPath.item),
                toOffset: destinationIndexPath.item + diff
            )
        }
    }

    func canStartDragAndDropSession(at indexPath: IndexPath) -> Bool {
        return sectionViewModel(at: indexPath)?.isDraggable ?? itemViewModel(at: indexPath).isDraggable
    }

    func onDragStart(at indexPath: IndexPath) {
        // Process further only if a section is currently being dragged
        guard indexPath.item == sectionHeaderItemIndex else { return }

        beginDragAndDropSession(forSectionWithIdentifier: sections[indexPath.section].id)
    }

    func onDragAnimationCompletion() {
        endDragAndDropSessionForCurrentlyDraggedSectionIfNeeded()
    }

    private func beginDragAndDropSession(forSectionWithIdentifier identifier: UUID) {
        guard let index = index(forSectionWithIdentifier: identifier) else { return }

        assert(
            currentlyDraggedSectionIdentifier == nil,
            "Attempting to start a new drag and drop session without finishing the previous one"
        )

        currentlyDraggedSectionIdentifier = identifier
        currentlyDraggedSectionItems = sections[index].items
        sections[index].items.removeAll()
    }

    private func endDragAndDropSession(forSectionWithIdentifier identifier: UUID) {
        guard let index = index(forSectionWithIdentifier: identifier) else { return }

        sections[index].items = currentlyDraggedSectionItems
        currentlyDraggedSectionItems.removeAll()
    }

    private func endDragAndDropSessionForCurrentlyDraggedSectionIfNeeded() {
        currentlyDraggedSectionIdentifier.map(endDragAndDropSession(forSectionWithIdentifier:))
        currentlyDraggedSectionIdentifier = nil
    }

    private func index(forSectionWithIdentifier identifier: UUID) -> Int? {
        return sections.firstIndex { $0.id == identifier }
    }

    private func itemViewModel(at indexPath: IndexPath) -> OrganizeTokensListItemViewModel {
        return sections[indexPath.section].items[indexPath.item]
    }

    private func sectionViewModel(at indexPath: IndexPath) -> OrganizeTokensListSectionViewModel? {
        guard indexPath.item == sectionHeaderItemIndex else { return nil }

        return sections[indexPath.section]
    }
}

// MARK: - OrganizeTokensDragAndDropControllerDataSource protocol conformance

extension OrganizeTokensViewModel: OrganizeTokensDragAndDropControllerDataSource {
    func numberOfSections(
        for controller: OrganizeTokensDragAndDropController
    ) -> Int {
        return sections.count
    }

    func controller(
        _ controller: OrganizeTokensDragAndDropController,
        numberOfRowsInSection section: Int
    ) -> Int {
        return sections[section].items.count
    }

    func controller(
        _ controller: OrganizeTokensDragAndDropController,
        listViewKindForItemAt indexPath: IndexPath
    ) -> OrganizeTokensDragAndDropControllerListViewKind {
        return indexPath.item == sectionHeaderItemIndex ? .sectionHeader : .cell
    }

    func controller(
        _ controller: OrganizeTokensDragAndDropController,
        listViewIdentifierForItemAt indexPath: IndexPath
    ) -> AnyHashable {
        return viewModelIdentifier(at: indexPath)
    }
}
