//
//  OrganizeTokensHeaderView.swift
//  Tangem
//
//  Created by Andrey Fedorov on 06.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct OrganizeTokensHeaderView: View {
    @ObservedObject var viewModel: OrganizeTokensHeaderViewModel

    @Environment(\.colorScheme) private var colorScheme

    private var buttonShadowOpacity: CGFloat {
        return colorScheme == .light ? Constants.lightModeButtonShadowOpacity : Constants.darkModeButtonShadowOpacity
    }

    var body: some View {
        HStack(spacing: 8.0) {
            Group {
                FlexySizeButtonWithLeadingIcon(
                    title: viewModel.sortByBalanceButtonTitle,
                    icon: Assets.OrganizeTokens.byBalanceSortIcon.image,
                    isToggled: viewModel.isSortByBalanceEnabled,
                    action: viewModel.toggleSortState
                )
                // TODO: Andrey Fedorov - Dark mode support for shadows (IOS-3927)
                .shadow(color: Colors.Background.action.opacity(sortByBalanceButtonShadowOpacity), radius: 5.0)

                FlexySizeButtonWithLeadingIcon(
                    title: viewModel.groupingButtonTitle,
                    icon: Assets.OrganizeTokens.makeGroupIcon.image,
                    action: viewModel.toggleGroupState
                )
                // TODO: Andrey Fedorov - Dark mode support for shadows (IOS-3927)
                .shadow(color: Colors.Background.action.opacity(groupingButtonShadowOpacity), radius: 5.0)
            }
            .background(
                Colors.Background
                    .primary
                    .cornerRadiusContinuous(10.0)
            )
            .onAppear(perform: viewModel.onViewAppear)
        }
    }

    private var sortByBalanceButtonShadowOpacity: CGFloat {
        return buttonShadowOpacity / (viewModel.isSortByBalanceEnabled ? 3.0 : 1.0)
    }

    private var groupingButtonShadowOpacity: CGFloat {
        return buttonShadowOpacity
    }
}

// MARK: - Constants

private extension OrganizeTokensHeaderView {
    enum Constants {
        static let lightModeButtonShadowOpacity = 0.1
        static let darkModeButtonShadowOpacity = 0.15
    }
}

// MARK: - Previews

struct OrganizeTokensHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let optionsManager = OrganizeTokensOptionsManagerStub()
        let viewModel = OrganizeTokensHeaderViewModel(
            optionsProviding: optionsManager,
            optionsEditing: optionsManager
        )
        return OrganizeTokensHeaderView(viewModel: viewModel)
    }
}
