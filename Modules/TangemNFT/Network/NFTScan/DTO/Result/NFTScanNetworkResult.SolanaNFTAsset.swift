//
//  NFTScanNetworkResult.SolanaNFTAsset.swift
//  TangemModules
//
//  Created by Mikhail Andreev on 3/7/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

extension NFTScanNetworkResult {
    struct Asset: Decodable {
        let blockNumber: Int
        let interactProgram: String
        let collection: String
        let tokenAddress: String
        let minter: String
        let owner: String
        let mintTimestamp: Int64
        let mintTransactionHash: String
        let mintPrice: Double
        let tokenURI: String
        let metadataJSON, name, contentType: String
        let contentURI, imageURI: String
        let externalLink: String
        let latestTradePrice: Double?
        let latestTradeSymbol: String?
        let latestTradeToken: String?
        let latestTradeTimestamp: Int64?
        let latestTradeTransactionHash: String?
    }
}
