//
//  NFTScanNetwrkResult.SolataNFTCollection.swift
//  TangemModules
//
//  Created by Mikhail Andreev on 3/7/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension NFTScanNetworkResult {
    struct SolanaNFTCollection: Decodable {
        let collection: String
        let logoURL: String
        let ownsTotal, itemsTotal: Int
        let description: String
        let assets: [Asset]
    }
}
