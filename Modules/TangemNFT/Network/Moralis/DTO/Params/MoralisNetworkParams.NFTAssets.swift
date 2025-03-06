//
//  MoralisNetworkParams.NFTAssets.swift
//  TangemNFT
//
//  Created by Andrey Fedorov on 05.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension MoralisNetworkParams {
    struct NFTAssets: Encodable {
        let chain: NFTChain?
        let normalizeMetadata: Bool?
        let mediaItems: Bool?
    }
}
