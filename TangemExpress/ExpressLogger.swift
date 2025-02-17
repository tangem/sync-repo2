//
//  ExpressLogger.swift
//  TangemApp
//
//  Created by Sergey Balashov on 27.01.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import TangemLogger

public let ExpressLogger = Logger(category: OSLogCategory(name: "Express"))
public let OnrampLogger = ExpressLogger.tag("Onramp")
