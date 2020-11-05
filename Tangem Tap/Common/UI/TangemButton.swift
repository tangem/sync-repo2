//
//  TangemButton.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 28.09.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct TangemButton: View {
    let isLoading: Bool    
    let title: LocalizedStringKey
    let image: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !self.isLoading {
                self.action()
            }
        }, label:  {
            HStack(alignment: .center, spacing: 8) {
                if isLoading {
                    ActivityIndicatorView()
                } else {
                    Text(title)
                    Image(image)
                }
            }
            .padding(.horizontal, 16)
            .frame(minWidth: ButtonSize.small.value.width,
                   maxWidth: .infinity,
                   minHeight: ButtonSize.small.value.height,
                   maxHeight: ButtonSize.small.value.height,
                   alignment: .center)
            .fixedSize()
        })
    }
}

struct TangemVerticalButton: View {
    let isLoading: Bool
    let title: LocalizedStringKey
    let image: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !self.isLoading {
                self.action()
            }
        }, label:  {
            VStack(alignment: .center, spacing: 0) {
                if isLoading {
                    ActivityIndicatorView()
                } else {
                    Image(image)
                    Text(title)
                }
            }
            .padding(.vertical, 8)
            .frame(minWidth: ButtonSize.smallVertical.value.width,
                   maxWidth: .infinity,
                   minHeight: ButtonSize.smallVertical.value.height,
                   maxHeight: ButtonSize.smallVertical.value.height,
                   alignment: .center)
            .fixedSize()
        })
    }
}

struct TangemLongButton: View {
    let isLoading: Bool
    let title: LocalizedStringKey
    let image: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !self.isLoading {
                self.action()
            }
        }, label: {
            HStack(alignment: .center, spacing: 8) {
                if isLoading {
                    ActivityIndicatorView()
                } else {
                    Text(title)
                    Spacer()
                    Image(image)
                }
            }
            .padding(.horizontal, 16)
            .frame(minWidth: ButtonSize.big.value.width,
                   maxWidth: .infinity,
                   minHeight: ButtonSize.big.value.height,
                   maxHeight: ButtonSize.big.value.height,
                   alignment: .center)
            .fixedSize()
        })
    }
}

struct TangemButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TangemButton(isLoading: false,
                         title: "wallet_button_scan",
                         image: "scan") {}
                .buttonStyle(TangemButtonStyle(color: .black))
            
            TangemVerticalButton(isLoading: false,
                                 title: "wallet_button_scan",
                                 image: "scan") {}
                .buttonStyle(TangemButtonStyle(color: .green))
            
            TangemLongButton(isLoading: false,
                             title: "wallet_button_scan",
                             image: "scan") {}
                .buttonStyle(TangemButtonStyle(color: .black))
            
        }
    }
}
