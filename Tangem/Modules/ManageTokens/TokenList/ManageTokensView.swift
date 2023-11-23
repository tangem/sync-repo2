//
//  ManageTokensView.swift
//  Tangem
//
//  Created by skibinalexander on 14.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine
import BlockchainSdk
import AlertToast

struct ManageTokensView: View {
    @ObservedObject var viewModel: ManageTokensViewModel

    var body: some View {
        ZStack {
            list

            overlay
        }
        .scrollDismissesKeyboardCompat(true)
        .alert(item: $viewModel.alert, content: { $0.alert })
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Localization.manageTokensListHeaderTitle)
                .style(Fonts.Bold.title1, color: Colors.Text.primary1)
                .lineLimit(1)

            Text(Localization.manageTokensListHeaderSubtitle)
                .style(Fonts.Regular.caption1, color: Colors.Text.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var list: some View {
        LazyVStack(spacing: 0) {
            header

            ForEach(viewModel.tokenViewModels) {
                ManageTokensItemView(viewModel: $0)
            }

            if viewModel.hasNextPage {
                HStack(alignment: .center) {
                    ActivityIndicatorView(color: .gray)
                        .onAppear(perform: viewModel.fetchMore)
                }
            }
        }
    }

    @ViewBuilder private var titleView: some View {
        Text(Localization.addTokensTitle)
            .style(Fonts.Bold.title1, color: Colors.Text.primary1)
    }

    // TODO: Andrey Fedorov - Should be placed over the token list as a floating overlay (IOS-5135)
    @ViewBuilder private var overlay: some View {
        if let generateAddressViewModel = viewModel.generateAddressesViewModel {
            VStack {
                Spacer()

                GenerateAddressesView(viewModel: generateAddressViewModel)
            }
        }
    }
}
