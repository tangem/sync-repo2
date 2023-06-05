//
//  PromotionService.swift
//  Tangem
//
//  Created by Andrey Chukavin on 31.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import TangemSdk
import BlockchainSdk

class PromotionService {
    @Injected(\.tangemApiService) private var tangemApiService: TangemApiService

    let programName = "1inch"
    private let promoCodeStorageKey = "promo_code"

    #warning("TODO: finalize")
    private let awardBlockchain: Blockchain = .polygon(testnet: false)
    private let awardToken: Token = .init(name: "1inch", symbol: "1INCH", contractAddress: "0x9c2c5fd7b07e95ee044ddeba0e97a665f142394f", decimalCount: 6, id: "1inch")

    init() {}
}

extension PromotionService: PromotionServiceProtocol {
    var promoCode: String? {
        let secureStorage = SecureStorage()
        guard
            let promoCodeData = try? secureStorage.get(promoCodeStorageKey),
            let promoCode = String(data: promoCodeData, encoding: .utf8)
        else {
            return nil
        }

        return promoCode
    }

    func setPromoCode(_ promoCode: String?) {
        do {
            let secureStorage = SecureStorage()

            if let promoCode {
                guard let promoCodeData = promoCode.data(using: .utf8) else { return }

                try secureStorage.store(promoCodeData, forKey: promoCodeStorageKey)
            } else {
                try secureStorage.delete(promoCodeStorageKey)
            }
        } catch {
            AppLog.shared.error(error)
            AppLog.shared.error("Failed to update promo code")
        }
    }

    func claimReward(userWalletId: String, storageEntryAdding: StorageEntryAdding) async throws {
        if let promoCode {
            let result = try await tangemApiService.validateNewUserPromotionEligibility(walletId: userWalletId, code: promoCode)

            guard let address = try await rewardAddress(storageEntryAdding: storageEntryAdding) else { return }

            try await tangemApiService.awardNewUser(walletId: userWalletId, address: address, code: promoCode)
        } else {
            // OLD USER

            let result = try await tangemApiService.validateOldUserPromotionEligibility(walletId: userWalletId, programName: programName)
            print(result)

            guard let address = try await rewardAddress(storageEntryAdding: storageEntryAdding) else { return }

            try await tangemApiService.awardOldUser(walletId: userWalletId, address: address, programName: programName)
        }
    }
}

extension PromotionService {
    private func rewardAddress(storageEntryAdding: StorageEntryAdding) async throws -> String? {
        let derivationPath: DerivationPath? = awardBlockchain.derivationPath()
        let blockchainNetwork = storageEntryAdding.getBlockchainNetwork(for: awardBlockchain, derivationPath: derivationPath)

        let entry = StorageEntry(blockchainNetwork: blockchainNetwork, token: awardToken)

        do {
            return try await storageEntryAdding.add(entry: entry)
        } catch {
            if error.toTangemSdkError().isUserCancelled {
                return nil
            } else {
                throw error
            }
        }
    }
}
