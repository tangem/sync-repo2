//
//  GroupedNumberTextField.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct GroupedNumberTextField: View {
    @Binding private var decimalValue: Decimal?
    @State private var textFieldText: String = ""

    private var placeholder: String = "0"
    private var groupedNumberFormatter: GroupedNumberFormatter
    private let numberFormatter: NumberFormatter = .grouped

    init(decimalValue: Binding<Decimal?>) {
        _decimalValue = decimalValue

        groupedNumberFormatter = GroupedNumberFormatter(
            maximumFractionDigits: 8,
            numberFormatter: numberFormatter
        )
    }

    private var textFieldProxyBinding: Binding<String> {
        Binding<String>(
            get: { groupedNumberFormatter.format(from: textFieldText) },
            set: { newValue in
                // If the field is empty
                // The field supports only decimal values
                guard newValue.isEmpty || Decimal(string: newValue) != nil else { return }

                // Remove space separators for formatter correct work
                var numberString = newValue.replacingOccurrences(of: " ", with: "")

                // If user double tap on zero, add "," to continue enter number
                if numberString == "00" {
                    numberString.insert(",", at: numberString.index(before: numberString.endIndex))
                }

                // If user start enter number with "," add zero before comma
                if numberString == "," {
                    numberString.insert("0", at: numberString.startIndex)
                }

                // If text already have "," remove last one
                if numberString.last == ",",
                   numberString.prefix(numberString.count - 1).contains(",") {
                    numberString.removeLast()
                }

                // Update private @State for display not correct number, like 0,000
                textFieldText = numberString

                // If string is correct number, update binding for work external updates
                if let value = numberFormatter.number(from: numberString) {
                    decimalValue = value.decimalValue
                } else if numberString.isEmpty {
                    decimalValue = nil
                }
            }
        )
    }

    var body: some View {
        TextField(placeholder, text: textFieldProxyBinding)
            .style(Fonts.Regular.title1, color: Colors.Text.primary1)
            .keyboardType(.decimalPad)
            .tintCompat(Colors.Text.primary1)
    }
}

extension GroupedNumberTextField: Setupable {
    func maximumFractionDigits(_ digits: Int) -> Self {
        map { $0.groupedNumberFormatter.update(maximumFractionDigits: digits) }
    }
}

struct GroupedNumberTextField_Previews: PreviewProvider {
    @State private static var decimalValue: Decimal?

    static var previews: some View {
        GroupedNumberTextField(decimalValue: $decimalValue)
    }
}
