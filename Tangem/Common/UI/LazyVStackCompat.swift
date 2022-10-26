//
//  LazyVStackCompat.swift
//  Tangem
//
//  Created by Sergey Balashov on 20.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct LazyVStackCompat<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let content: () -> Content
    
    init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            LazyVStack(alignment: alignment, spacing: spacing, content: content)
        } else {
            VStack(alignment: alignment, spacing: spacing, content: content)
        }
    }
}
