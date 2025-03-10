//
//  NFTScanAPITarget.swift
//  TangemModules
//
//  Created by Mikhail Andreev on 3/7/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemNetworkUtils
import Moya

struct NFTScanAPITarget {
    let target: Target
}

extension NFTScanAPITarget {
    enum Target {
        /// https://docs.nftscan.com/reference/solana/get-all-nfts-by-account
        case getNFTCollectionsByAddress(address: String, params: NFTScanNetworkParams.NFTCollectionsByAddress)

        /// https://docs.nftscan.com/reference/solana/get-single-nft
        case getNFTByTokenID(tokenID: String, params: NFTScanNetworkParams.NFTByTokenID)
    }
}

extension NFTScanAPITarget: TargetType {
    var baseURL: URL {
        URL(string: "https://solanaapi.nftscan.com/api/")!
    }

    var path: String {
        switch target {
        case .getNFTByTokenID(let tokenID, let params):
            "\(params.chain)/assets/\(tokenID)?show_attribute=\(params.showAttribute)"
        case .getNFTCollectionsByAddress(let address, let params):
            "\(params.chain)/account/own/all/\(address)?show_attribute=\(params.showAttribute)"
        }
    }
    
    var method: Moya.Method {
        switch target {
        case .getNFTByTokenID, .getNFTCollectionsByAddress:
                .get
        }
    }
    
    var task: Moya.Task {
        switch target {
        case .getNFTByTokenID, .getNFTCollectionsByAddress:
            .requestPlain
        }
    }
    
    var headers: [String : String]? { nil }
}
