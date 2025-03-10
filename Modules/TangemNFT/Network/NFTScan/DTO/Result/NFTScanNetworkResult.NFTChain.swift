//
//  NFTScanNetworkResult.NFTChain.swift
//  TangemModules
//
//  Created by Mikhail Andreev on 3/7/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

extension NFTScanNetworkParams {
    /// Taken from https://docs.nftscan.com/
    /// Not planning to sue it with EVMs
    /// valid on 07.03.2025
    enum NFTChain: String {
        case bitcoin = "btc"
        case aptos = "apt"
        case solana = "sol"
        case ton
    }
}
