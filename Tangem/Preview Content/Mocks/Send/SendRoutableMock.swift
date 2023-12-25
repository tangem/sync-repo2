//
//  SendRoutableMock.swift
//  Tangem
//
//  Created by Andrey Chukavin on 02.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

class SendRoutableMock: SendRoutable {
    init() {}

    func openQRScanner(with codeBinding: Binding<String>) {}
}
