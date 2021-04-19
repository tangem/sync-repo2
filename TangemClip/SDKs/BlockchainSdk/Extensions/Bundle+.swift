//
//  Bundle+.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 01.09.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

extension Bundle {
     static var blockchainBundle: Bundle {
        let selfBundle = Bundle(for: WalletManager.self)
        if let path = selfBundle.path(forResource: "BlockchainSdkClips", ofType: "bundle"), //for pods
            let bundle = Bundle(path: path) {
            return bundle
        } else {
            return selfBundle
        }
    }
}
