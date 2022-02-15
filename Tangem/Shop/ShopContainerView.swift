//
//  ShopContainerView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 10.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct ShopContainerView: View {
    @ObservedObject var viewModel: ShopViewModel
    
    var body: some View {
        if let order = viewModel.order {
            ShopOrderView(order: order)
        } else if viewModel.pollingForOrder {
            ShopOrderProgressView()
        } else {
            ShopView(viewModel: viewModel)
        }
    }
}
