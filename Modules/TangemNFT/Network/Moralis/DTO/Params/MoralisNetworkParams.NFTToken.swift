//
//  MoralisNetworkParams.NFTToken.swift
//  TangemNFT
//
//  Created by Andrey Fedorov on 05.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension MoralisNetworkParams {
    struct NFTToken: Encodable {
        let tokenAddress: String
        let tokenId: String
    }
}
