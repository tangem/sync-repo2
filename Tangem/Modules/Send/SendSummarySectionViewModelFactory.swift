//
//  SendSummarySectionViewModelFactory.swift
//  Tangem
//
//  Created by Andrey Chukavin on 09.01.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

struct SendSummarySectionViewModelFactory {
    private let tokenItem: TokenItem
    private let currencyId: String?
    private let tokenIconInfo: TokenIconInfo

    private var feeFormatter: SwappingFeeFormatter {
        CommonSwappingFeeFormatter(
            balanceFormatter: BalanceFormatter(),
            balanceConverter: BalanceConverter(),
            fiatRatesProvider: SwappingRatesProvider()
        )
    }

    init(tokenItem: TokenItem, currencyId: String?, tokenIconInfo: TokenIconInfo) {
        self.tokenItem = tokenItem
        self.currencyId = currencyId
        self.tokenIconInfo = tokenIconInfo
    }

    func makeDestinationViewTypes(address: String, additionalField: (SendAdditionalFields, String)?) -> [SendDestinationSummaryViewType] {
        var destinationViewTypes: [SendDestinationSummaryViewType] = [
            .address(address: address),
        ]

        if let (additionalFieldType, additionalFieldValue) = additionalField {
            destinationViewTypes.append(.additionalField(type: additionalFieldType, value: additionalFieldValue))
        }

        return destinationViewTypes
    }

    func makeAmountViewData(from amount: Amount?) -> AmountSummaryViewData? {
        guard let amount else { return nil }

        let formattedAmount = amount.description

        let amountFiat: String?
        if let currencyId,
           let fiatValue = BalanceConverter().convertToFiat(value: amount.value, from: currencyId) {
            amountFiat = fiatValue.currencyFormatted(code: AppSettings.shared.selectedCurrencyCode, maximumFractionDigits: 2)
        } else {
            amountFiat = nil
        }
        return AmountSummaryViewData(
            title: Localization.sendAmountLabel,
            amount: formattedAmount,
            amountFiat: amountFiat ?? "",
            tokenIconInfo: tokenIconInfo
        )
    }

    func makeFeeViewData(from value: Fee?) -> DefaultTextWithTitleRowViewData? {
        guard let value else { return nil }

        let formattedValue = feeFormatter.format(
            fee: value.amount.value,
            tokenItem: tokenItem
        )

        return DefaultTextWithTitleRowViewData(title: Localization.sendNetworkFeeTitle, text: formattedValue)
    }
}
