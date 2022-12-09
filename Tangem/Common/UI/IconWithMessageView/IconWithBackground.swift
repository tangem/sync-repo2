//
//  IconWithBackground.swift
//  Tangem
//
//  Created by Andrew Son on 07/11/22.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct IconWithBackground: View {
    struct Settings {
        let backgroundColor: Color
        let padding: CGFloat
        let cornerRadius: CGFloat
    }
    private let icon: Image
    private let settings: Settings

    init(
        icon: Image,
        settings: Settings = .init(backgroundColor: Colors.Button.secondary,
                                   padding: 14,
                                   cornerRadius: 16)
    ) {
        self.icon = icon
        self.settings = settings
    }

    var body: some View {
        icon
            .roundedBackground(with: settings.backgroundColor,
                               padding: settings.padding,
                               radius: settings.cornerRadius)
    }
}

struct ReferralPointIcon_Previews: PreviewProvider {
    static var previews: some View {
        IconWithBackground(icon: Assets.discount)
    }
}
