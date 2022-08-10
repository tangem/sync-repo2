//
//  UserWalletListService.swift
//  Tangem
//
//  Created by Andrey Chukavin on 05.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol UserWalletListService: AnyObject, Initializable {
    var models: [CardViewModel] { get }

    var selectedUserWalletId: Data? { get set }

    func deleteWallet(_ userWallet: UserWallet)
    func contains(_ userWallet: UserWallet) -> Bool
    func save(_ userWallet: UserWallet) -> Bool
    func setName(_ userWallet: UserWallet, name: String)
}

private struct UserWalletListServiceKey: InjectionKey {
    static var currentValue: UserWalletListService = CommonUserWalletListService()
}

extension InjectedValues {
    var userWalletListService: UserWalletListService {
        get { Self[UserWalletListServiceKey.self] }
        set { Self[UserWalletListServiceKey.self] = newValue }
    }
}
