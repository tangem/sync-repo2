//
//  MultiWalletMainContentView.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct MultiWalletMainContentView: View {
    @ObservedObject var viewModel: MultiWalletMainContentViewModel

    var body: some View {
        VStack {
            Text("Hello, Multiwallet!")
        }
    }
}

struct MultiWalletContentView_Preview: PreviewProvider {
    static let viewModel = MultiWalletMainContentViewModel(coordinator: MainCoordinator())

    static var previews: some View {
        MultiWalletMainContentView(viewModel: viewModel)
    }
}
