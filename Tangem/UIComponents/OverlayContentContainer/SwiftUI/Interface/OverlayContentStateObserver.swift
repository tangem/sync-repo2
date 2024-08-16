//
//  OverlayContentStateObserver.swift
//  Tangem
//
//  Created by m3g0byt3 on 16.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

protocol OverlayContentStateObserver {
    @available(*, deprecated, message: "Replace with dedicated type (IOS-7364)")
    typealias Observer = BottomScrollableSheetStateObserver
    @available(*, deprecated, message: "Replace with dedicated type (IOS-7364)")
    typealias State = BottomScrollableSheetState

    /// - Warning: This method maintains a strong reference to the given `observer` closure.
    /// Remove this reference by using `removeObserver(forToken:)` method.
    func addObserver(_ observer: @escaping Observer, forToken token: any Hashable)
    func removeObserver(forToken token: any Hashable)
}
