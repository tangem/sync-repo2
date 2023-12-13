//
//  ExpressProvider.swift
//  TangemSwapping
//
//  Created by Sergey Balashov on 02.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

public struct ExpressProvider: Hashable {
    public typealias Id = String

    public let id: Id
    public let name: String
    public let url: URL?
    public let type: ExpressProviderType

    public init(id: Id, name: String, url: URL?, type: ExpressProviderType) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
    }
}
