//
//  IncomingActionConstants.swift
//  Tangem
//
//  Created by Alexander Osokin on 24.01.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

enum IncomingActionConstants {
    static let appTangemDomain = "https://app.tangem.com"
    static let universalLinkScheme = "tangem://"
    static let tangemDomain = AppConstants.tangemDomainUrl.absoluteString
    static let ndefURL = "\(appTangemDomain)/ndef"
    static let redirectBaseURL = "\(tangemDomain)/redirect"
    static let incoimingActionName = "action"
}
