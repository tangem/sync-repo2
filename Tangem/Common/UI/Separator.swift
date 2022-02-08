//
//  Separator.swift
//  Tangem
//
//  Created by Andrew Son on 16/06/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

struct Separator: View {
    let height: Double
    
    var body: some View {
        Color.tangemGrayLight5
            .frame(width: nil, height: height, alignment: .center)
            .padding(.vertical, 4.0)
    }
    
    init(height: Double = 1.0) {
        self.height = height
    }
}
