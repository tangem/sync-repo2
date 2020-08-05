//
//  ButtonView.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 03.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

enum ButtonSize: CGFloat {
    case small = 93.0
    case big = 200.0
}

enum ButtonColorStyle {
    case green
    case black
}

struct TangemButtonStyle: ButtonStyle {
    var size: ButtonSize = .small
    var colorStyle: ButtonColorStyle = .green
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(Font.custom("SairaSemiCondensed-Bold", size: 14.0))
            .foregroundColor(Color.white)
            .frame(width: size.rawValue, height: 56.0, alignment: .center)
            .background(configuration.isPressed ?
                (colorStyle == .green ? Color.tangemTapGreen : Color.tangemTapBlack) :
                (colorStyle == .green ? Color.tangemTapGreen : Color.tangemTapBlack))
            .cornerRadius(8)
            .fixedSize()
    }
}

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center, spacing: 16.0) {
            Button(action:{}){
                Text("Tap in!")}
                .buttonStyle(TangemButtonStyle(size: .small, colorStyle: .green))
            
            
            Button(action: {}) { Text("Tap in!") }
                .buttonStyle(TangemButtonStyle(size: .small, colorStyle: .black))
            
            Button(action: {}) { Text("No. Go to shop") }
                .buttonStyle(TangemButtonStyle(size: .big, colorStyle: .green))
            
            Button(action: {}) { Text("No. Go to shop") }
                .buttonStyle(TangemButtonStyle(size: .big, colorStyle: .black))
        }
    }
}
