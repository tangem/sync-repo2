//
//  SaltPayConfig.swift
//  Tangem
//
//  Created by Alexander Osokin on 09.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

struct SaltPayConfiguration: Decodable {
    let sprinklr: SprinklrProvider
    let kycProvider: KYCProvider
    let credentials: NetworkProviderConfiguration.Credentials
}

struct KYCProvider: Decodable {
    let baseUrl: String
    let externalIdParameterKey: String
    let sidParameterKey: String
    let sidValue: String
}

struct SprinklrProvider: Decodable {
    let appID: String
    let baseURL: String
}
