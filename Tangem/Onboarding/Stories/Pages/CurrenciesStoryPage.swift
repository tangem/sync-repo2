//
//  CurrenciesStoryPage.swift
//  Tangem
//
//  Created by Andrey Chukavin on 14.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct CurrenciesStoryPage: View {
    var scanCard: (() -> Void)
    var orderCard: (() -> Void)
    
    var body: some View {
        VStack {
            Text("story_currencies_title")
                .font(.system(size: 36, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding()
            
            Text("story_currencies_description")
                .font(.system(size: 22))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Spacer()
            

            Image("currencies")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Spacer()
            
            HStack {
                Button {
                    scanCard()
                } label: {
                    Text("home_button_scan")
                }
                .buttonStyle(TangemButtonStyle(colorStyle: .grayAlt, layout: .flexibleWidth))
                
                Button {
                    orderCard()
                } label: {
                    Text("home_button_order")
                }
                .buttonStyle(TangemButtonStyle(colorStyle: .black, layout: .flexibleWidth))
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CurrenciesStoryPage_Previews: PreviewProvider {
    static var previews: some View {
        CurrenciesStoryPage { } orderCard: { }
    }
}
