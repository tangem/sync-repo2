//
//  WriteIdTask.swift
//  Tangem
//
//  Created by Alexander Osokin on 20.03.2020.
//  Copyright © 2020 Smart Cash AG. All rights reserved.
//

import Foundation
import TangemSdk

@available(iOS 13.0, *)
class WriteIdTask: WriteIssuerExtraDataTask {
    public override var startMessage: String? { return "Hold your iPhone near the ID card" }
}
