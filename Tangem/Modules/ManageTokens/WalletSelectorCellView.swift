//
//  WalletSelectorCellView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 13.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct WalletSelectorCellView: View {
    var image: UIImage?
    let name: String
    let isSelected: Bool

    private let imageHeight = 30.0
    private let maxImageWidth = 50.0

    var body: some View {
        HStack(spacing: 12) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: maxImageWidth, minHeight: imageHeight, maxHeight: imageHeight)
            } else {
                SkeletonView()
                    .cornerRadius(3)
                    .frame(width: maxImageWidth, height: imageHeight)
            }

            Text(name)
                .lineLimit(1)
                .style(Fonts.Regular.subheadline, color: Colors.Text.primary1)

            Spacer(minLength: 0)

            if isSelected {
                Assets.check.image
                    .frame(width: 20, height: 20)
                    .foregroundColor(Colors.Icon.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 19)
    }
}

struct WalletSelectorCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WalletSelectorCellView(image: nil, name: "My Wallet", isSelected: false)

            WalletSelectorCellView(image: UIImage(named: "tangem-card"), name: "My Wallet 2.0", isSelected: true)

            WalletSelectorCellView(image: UIImage(named: "tangem-card"), name: "My Wallet 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0", isSelected: false)
        }
    }
}
