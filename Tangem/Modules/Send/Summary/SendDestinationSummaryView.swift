//
//  SendDestinationSummaryView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 07.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct SendDestinationSummaryView: View {
    private let viewModels: [SendDestinationSummaryViewModel]

    init(address: String, additionalFieldType: SendAdditionalFields, additionalFieldValue: String?) {
        var viewModels = [
            SendDestinationSummaryViewModel(type: .address(address: address)),
        ]

        if let additionalFieldValue, additionalFieldType != .none {
            viewModels.append(
                SendDestinationSummaryViewModel(type: .additionalField(type: additionalFieldType, value: additionalFieldValue))
            )
        }

        self.viewModels = viewModels
    }

    var body: some View {
        GroupedSection(viewModels) { viewModel in
            switch viewModel.type {
            case .address(let address):
                addressView(address: address)
            case .additionalField(let type, let value):
                additionalFieldView(type: type, value: value)
            }
        }
        .horizontalPadding(14)
        .separatorStyle(.single)
    }

    @ViewBuilder
    private func addressView(address: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Localization.sendRecipient)
                .style(Fonts.Regular.caption1, color: Colors.Text.secondary)

            HStack(spacing: 12) {
                AddressIconView(viewModel: AddressIconViewModel(address: address))
                    .frame(size: CGSize(bothDimensions: 36))

                Text(address)
                    .style(Fonts.Regular.subheadline, color: Colors.Text.primary1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func additionalFieldView(type: SendAdditionalFields, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(type.name)
                .style(Fonts.Regular.caption1, color: Colors.Text.secondary)

            Text(value)
                .style(Fonts.Regular.footnote, color: Colors.Text.primary1)
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    GroupedScrollView {
        SendDestinationSummaryView(
            address: "1230123",
            additionalFieldType: .none,
            additionalFieldValue: ""
        )

        SendDestinationSummaryView(
            address: "0x391316d97a07027a0702c8A002c8A0C25d8470",
            additionalFieldType: .none,
            additionalFieldValue: ""
        )

        SendDestinationSummaryView(
            address: "0x391316d97a07027a0702c8A002c8A0C25d8470",
            additionalFieldType: .memo,
            additionalFieldValue: "123456789"
        )

        SendDestinationSummaryView(
            address: "0x391316d97a07027a0702c8A002c8A0C25d84700x391316d97a07027a0702c8A002c8A0C25d84700x391316d97a07027a0702c8A002c8A0C25d84700x391316d97a07027a0702c8A002c8A0C25d8470",
            additionalFieldType: .destinationTag,
            additionalFieldValue: "123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789123456789"
        )
    }
    .background(Colors.Background.secondary.edgesIgnoringSafeArea(.all))
}
