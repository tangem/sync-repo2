//
//  CardsRepository.swift
//  Tangem
//
//  Created by Alexander Osokin on 03.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import enum TangemSdk.EllipticCurve
import struct TangemSdk.Card
import struct TangemSdk.ExtendedPublicKey
import struct TangemSdk.WalletData
import struct TangemSdk.ArtworkInfo
import struct TangemSdk.PrimaryCard
import struct TangemSdk.DerivationPath
import class TangemSdk.TangemSdk
import enum TangemSdk.TangemSdkError

import Intents

class CommonCardsRepository: CardsRepository {
    @Injected(\.tangemSdkProvider) private var sdkProvider: TangemSdkProviding
    @Injected(\.scannedCardsRepository) private var scannedCardsRepository: ScannedCardsRepository
    @Injected(\.tangemApiService) private var tangemApiService: TangemApiService
    @Injected(\.backupServiceProvider) private var backupServiceProvider: BackupServiceProviding

    var didScanPublisher: PassthroughSubject<CardInfo, Never> = .init()

    private(set) var cards = [String: CardViewModel]()

    private var bag: Set<AnyCancellable> = .init()
    private let legacyCardMigrator: LegacyCardMigrator = .init()

    deinit {
        print("CardsRepository deinit")
    }

    func scan(with batch: String? = nil, _ completion: @escaping (Result<CardViewModel, Error>) -> Void) {
        Analytics.log(event: .readyToScan)
        sdkProvider.prepareScan()
        sdkProvider.sdk.startSession(with: AppScanTask(targetBatch: batch)) { [unowned self] result in
            switch result {
            case .failure(let error):
                Analytics.logCardSdkError(error, for: .scan)
                completion(.failure(error))
            case .success(let response):
                completion(.success(processScan(response.getCardInfo())))
            }
        }
    }

    func scanPublisher(with batch: String? = nil) -> AnyPublisher<CardViewModel, Error>  {
        Deferred {
            Future { [weak self] promise in
                self?.scan(with: batch) { result in
                    switch result {
                    case .success(let scanResult):
                        promise(.success(scanResult))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func processScan(_ cardInfo: CardInfo) -> CardViewModel {
        let interaction = INInteraction(intent: ScanTangemCardIntent(), response: nil)
        interaction.donate(completion: nil)

        cardInfo.primaryCard.map { backupServiceProvider.backupService.setPrimaryCard($0) }

        let cm = CardViewModel(cardInfo: cardInfo)
        legacyCardMigrator.migrateIfNeeded(for: cardInfo.card.cardId, config: cm.config)
        scannedCardsRepository.add(cardInfo)
        didScanPublisher.send(cardInfo)
        tangemApiService.setAuthData(cardInfo.card.tangemApiAuthData)

        Analytics.logScan(card: cardInfo.card, config: cm.config)
        cards[cardInfo.card.cardId] = cm
        sdkProvider.didScan(cm.config)
        cm.getCardInfo()
        return cm
    }
}


/// Temporary solution to migrate default tokens of old miltiwallet cards to TokenItemsRepository. Remove at Q3-Q4'22
fileprivate class LegacyCardMigrator {
    @Injected(\.tokenItemsRepository) private var tokenItemsRepository: TokenItemsRepository
    @Injected(\.scannedCardsRepository) private var scannedCardsRepository: ScannedCardsRepository

    // Save default blockchain and token to main tokens repo.
    func migrateIfNeeded(for cardId: String, config: UserWalletConfig) {
        // Migrate only multiwallet cards
        guard config.hasFeature(.manageTokens) else {
            return
        }

        // Check if we have anything to migrate. It's impossible to get default token without default blockchain
        guard let embeddedEntry = config.embeddedBlockchain else {
            return
        }

        // Migrate only known cards.
        guard scannedCardsRepository.cards.keys.contains(cardId) else {
            // Newly scanned card. Save and forgot.
            AppSettings.shared.migratedCardsWithDefaultTokens.append(cardId)
            return
        }

        // Migrate only once.
        guard !AppSettings.shared.migratedCardsWithDefaultTokens.contains(cardId) else {
            return
        }

        var entries = tokenItemsRepository.getItems(for: cardId)
        entries.insert(embeddedEntry, at: 0)

        // We need to preserve order of token items
        tokenItemsRepository.removeAll(for: cardId)
        tokenItemsRepository.append(entries, for: cardId)

        AppSettings.shared.migratedCardsWithDefaultTokens.append(cardId)
    }
}
