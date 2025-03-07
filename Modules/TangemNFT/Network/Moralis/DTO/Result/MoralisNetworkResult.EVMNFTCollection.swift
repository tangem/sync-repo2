//
//  MoralisNetworkResult.EVMNFTCollection.swift
//  TangemNFT
//
//  Created by Andrey Fedorov on 03.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension MoralisNetworkResult {
    struct EVMNFTCollection: Decodable {
        let tokenAddress: String?
        let possibleSpam: Bool?
        let contractType: String?
        let name: String?
        let symbol: String?
        let verifiedCollection: Bool?
        let collectionLogo: URL?
        let collectionBannerImage: URL?
        let floorPrice: String?
        let floorPriceUsd: String?
        let floorPriceCurrency: String?
        let count: Int?
    }
}
