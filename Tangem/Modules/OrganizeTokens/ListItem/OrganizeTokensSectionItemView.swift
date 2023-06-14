//
//  OrganizeTokensSectionItemView.swift
//  Tangem
//
//  Created by Andrey Fedorov on 06.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct OrganizeTokensSectionItemView: View {
    let viewModel: OrganizeTokensListItemViewModel

    var body: some View {
        HStack(spacing: 12.0) {
            TokenItemViewLeadingComponent(
                name: viewModel.name,
                imageURL: viewModel.imageURL,
                blockchainIconName: viewModel.blockchainIconName,
                networkUnreachable: viewModel.networkUnreachable
            )

            TokenItemViewMiddleComponent(
                name: viewModel.name,
                balance: viewModel.balance,
                hasPendingTransactions: viewModel.hasPendingTransactions,
                networkUnreachable: viewModel.networkUnreachable
            )

            Spacer(minLength: 0.0)

            if viewModel.isDraggable {
                Assets.OrganizeTokens.itemDragAndDropIcon
                    .image
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(size: .init(bothDimensions: 20.0))
                    .foregroundColor(Colors.Icon.informative)
                    .layoutPriority(1.0)
            }
        }
        .padding(.horizontal, 14.0)
        .frame(height: 68.0)
    }
}

// MARK: - Previews

struct OrganizeTokensSectionItemView_Previews: PreviewProvider {
    private static let previewProvider = OrganizeTokensPreviewProvider()

    static var previews: some View {
        VStack {
            Group {
                let viewModels = previewProvider
                    .singleMediumSection()
                    .flatMap(\.items)

                ForEach(viewModels) { viewModel in
                    OrganizeTokensSectionItemView(viewModel: viewModel)
                }
            }
            .background(Colors.Background.primary)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Colors.Background.secondary)
    }
}
