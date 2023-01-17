//
//  WalletConnectUIDelegate.swift
//  Tangem
//
//  Created by Andrew Son on 14/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct WalletConnectUIRequest {
    let event: WalletConnectEvent
    let message: String
    var positiveReactionAction: () -> Void
    var negativeReactionAction: (() -> Void)?
}

protocol WalletConnectUIDelegate {
    func showScreen(with request: WalletConnectUIRequest)
}

struct WalletConnectAlertUIDelegate {
    private let appPresenter: AppPresenter = .shared
}

extension WalletConnectAlertUIDelegate: WalletConnectUIDelegate {
    func showScreen(with request: WalletConnectUIRequest) {
        let alert = WalletConnectUIBuilder.makeAlert(
            for: request.event,
            message: request.message,
            onAcceptAction: request.positiveReactionAction,
            onReject: request.negativeReactionAction ?? {}
        )

        appPresenter.show(alert)
    }
}
