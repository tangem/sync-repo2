//
//  ActionButtonsBuyFlowRoutable.swift
//  TangemApp
//
//  Created by GuitarKitty on 06.11.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

protocol ActionButtonsBuyFlowRoutable {
    func openBuy(userWalletModel: some UserWalletModel)
    func openP2PTutorial()
    func openBankWarning(confirmCallback: @escaping () -> Void, declineCallback: @escaping () -> Void)
}
