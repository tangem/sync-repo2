//
//  Card+.swift
//  Tangem
//
//  Created by Andrew Son on 27/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import TangemSdk

#if !CLIP
import BlockchainSdk
#endif

extension CardDTO {
    var walletSignedHashes: Int {
        wallets.compactMap { $0.totalSignedHashes }.reduce(0, +)
    }

    var walletCurves: [EllipticCurve] {
        wallets.compactMap { $0.curve }
    }

    #if !CLIP
    var derivationStyle: DerivationStyle {
        CardDTO.getDerivationStyle(for: batchId, isHdWalletAllowed: settings.isHDWalletAllowed)
    }

    var tangemApiAuthData: TangemApiTarget.AuthData {
        .init(cardId: cardId, cardPublicKey: cardPublicKey)
    }

    static func getDerivationStyle(for batchId: String, isHdWalletAllowed: Bool) -> DerivationStyle {
        guard isHdWalletAllowed else {
            return .legacy
        }

        let batchId = batchId.uppercased()

        if BatchId.isDetached(batchId) {
            return .legacy
        }

        return .new
    }

    #endif
}
