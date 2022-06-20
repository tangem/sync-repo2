//
//  ShopCoordinator.swift
//  Tangem
//
//  Created by Alexander Osokin on 15.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

class ShopCoordinator: CoordinatorObject {
    //MARK: - View models
    @Published private(set) var shopViewModel: ShopViewModel? = nil
    @Published var pushedWebViewModel: WebViewContainerViewModel? = nil
    
    @Published var webShopUrl: URL? = nil
    
    var dismissAction: () -> Void = {}
    
    func start() {
        if Locale.current.regionCode == "RU" {
            webShopUrl = URL(string: "https://mv.tangem.com")
        } else {
            shopViewModel = ShopViewModel(coordinator: self)
        }
    }
}

extension ShopCoordinator: ShopViewRoutable {
    func openWebCheckout(at url: URL) {
        pushedWebViewModel = WebViewContainerViewModel(url: url,
                                                       title: "shop_web_checkout_title".localized,
                                                       addLoadingIndicator: true)
    }
    
    func closeWebCheckout() {
        pushedWebViewModel = nil
    }
}
