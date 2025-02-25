//
//  VanarExternalLinkProvider.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 2/12/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

struct VanarExternalLinkProvider: ExternalLinkProvider {
    private let baseExplorerUrl: String

    let testnetFaucetURL = URL(string: "https://faucet.vanarchain.com/")

    init(isTestnet: Bool) {
        baseExplorerUrl = isTestnet
            ? "https://explorer-vanguard.vanarchain.com"
            : "https://explorer.vanarchain.com"
    }

    func url(address: String, contractAddress: String?) -> URL? {
        URL(string: "\(baseExplorerUrl)/address/\(address)")
    }

    func url(transaction hash: String) -> URL? {
        URL(string: "\(baseExplorerUrl)/tx/\(hash)")
    }
}
