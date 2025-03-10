//
//  NFTScanNetworkResult.SolanaNFTCollections.swift
//  TangemModules
//
//  Created by Mikhail Andreev on 3/7/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

extension NFTScanNetworkResult {
    struct SolanaNFTScanResponse<T: Decodable> {
        let code: Int
        let msg: String?
        let data: T
    }
}
