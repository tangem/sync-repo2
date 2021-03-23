//
//  BalanceView.swift
//  TangemClip
//
//  Created by Andrew Son on 09/03/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import TangemSdkClips
import BlockchainSdkClips

struct TokenBalanceView: View {
    var tokenViewModel: TokenBalanceViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(tokenViewModel.name)
                Spacer()
                Text(tokenViewModel.balance)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.tangemTapGrayDark6)
            .padding(.bottom, 2)
            HStack {
                Spacer()
                Text(tokenViewModel.fiatBalance)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.tangemTapGrayDark)
            }
        }
        .padding(8)
        .background(Color.tangemTapGrayLight6)
        .cornerRadius(6)
    }
}

struct BalanceView: View {
    var balanceViewModel: BalanceViewModel
    var tokenViewModels: [TokenBalanceViewModel]
    
    var blockchainText: String {
        if balanceViewModel.hasTransactionInProgress {
            return  "wallet_balance_tx_in_progress".localized
        }
        
        return "wallet_balance_verified".localized
    }
    
    var image: String {
        "checkmark.circle"
    }
    
    var accentColor: Color {
        return .tangemTapWarning
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Color.clear.frame(height: 16)

            HStack(alignment: .firstTextBaseline) {
                Text(balanceViewModel.name)
                    .font(Font.system(size: 20.0, weight: .bold, design: .default))
                    .foregroundColor(Color.tangemTapGrayDark6)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text(balanceViewModel.balance)
                    .font(Font.system(size: 20.0, weight: .bold, design: .default))
                    .foregroundColor(Color.tangemTapGrayDark6)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.trailing)
                    .truncationMode(.middle)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24.0)
            .padding(.bottom, 8)
            
            
            HStack(alignment: .firstTextBaseline, spacing: 5.0) {
                Image(!balanceViewModel.hasTransactionInProgress ? "checkmark.circle" : "exclamationmark.circle" )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(accentColor)
                    .frame(width: 10.0, height: 10.0)
                    .font(Font.system(size: 14.0, weight: .medium, design: .default))
                VStack(alignment: .leading) {
                    Text(blockchainText)
                        .font(Font.system(size: 14.0, weight: .medium, design: .default))
                        .foregroundColor(accentColor)
                        .lineLimit(1)
                }
                Spacer()
                Text(balanceViewModel.fiatBalance)
                    .font(Font.system(size: 14.0, weight: .medium, design: .default))
                    .lineLimit(1)
                    .foregroundColor(Color.tangemTapGrayDark)
            }
            .padding(.bottom, 16.0)
            .padding(.horizontal, 24.0)
            
            
            if balanceViewModel.isToken {
                Color.tangemTapGrayLight5
                    .frame(width: nil, height: 1.0, alignment: .center)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 24.0)
                HStack(alignment: .firstTextBaseline) {
                    Text(balanceViewModel.secondaryName)
                        .font(Font.system(size: 14.0, weight: .medium, design: .default))
                        .foregroundColor(Color.tangemTapGrayDark6)
                        .lineLimit(1)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(balanceViewModel.secondaryBalance)
                            .font(Font.system(size: 13.0, weight: .medium, design: .default))
                            .foregroundColor(Color.tangemTapGrayDark6)
                            .lineLimit(1)
                        Text(balanceViewModel.secondaryFiatBalance)
                            .font(Font.system(size: 13.0, weight: .medium, design: .default))
                            .lineLimit(1)
                            .foregroundColor(Color.tangemTapGrayDark)
                    }
                    
                }
                .padding(.horizontal, 24.0)
                
                Color.clear.frame(height: 16)
            } else if tokenViewModels.count > 0 {
                VStack(spacing: 8) {
                    ForEach(tokenViewModels, id: \.tokenName) { token in
                        TokenBalanceView(tokenViewModel: token)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
            }
        }
        .background(Color.white)
        .cornerRadius(6.0)
    }
}

struct BalanceView_Previews: PreviewProvider {
    
    static let tokens = [
        TokenBalanceViewModel(token: Token(name: "SushiSwap", symbol: "SUSHI", contractAddress: "", decimalCount: 18), balance: "163.7425436", fiatBalance: "$ 2241.31")
    ]
    
    static var previews: some View {
        ZStack {
            Color.tangemTapBgGray
            VStack {
                BalanceView(balanceViewModel: BalanceViewModel(isToken: false,
                                                               hasTransactionInProgress: false,
                                                               name: "Ethereum smart contract token",
                                                               fiatBalance: "$3.45",
                                                               balance: "0.00000348573986753845001 BTC",
                                                               secondaryBalance: "", secondaryFiatBalance: "",
                                                               secondaryName: ""),
                            tokenViewModels: tokens)
                    .padding(.horizontal, 16)
                
                BalanceView(balanceViewModel: BalanceViewModel(isToken: false,
                                                               hasTransactionInProgress: false,
                                                               name: "Ethereum smart contract token",
                                                               fiatBalance: "$3.45",
                                                               balance: "0.00000348573986753845001 BTC",
                                                               secondaryBalance: "", secondaryFiatBalance: "",
                                                               secondaryName: ""),
                            tokenViewModels: tokens)
                    .padding(.horizontal, 16)
                
                BalanceView(balanceViewModel: BalanceViewModel(isToken: true,
                                                               hasTransactionInProgress: false,
                                                               name: "Ethereum smart contract token",
                                                               fiatBalance: " ",
                                                               balance: "-",
                                                               secondaryBalance: "-",
                                                               secondaryFiatBalance: "",
                                                               secondaryName: "Bitcoin"),
                            tokenViewModels: tokens)
                    .padding(.horizontal, 16)
                
                BalanceView(balanceViewModel: BalanceViewModel(isToken: true,
                                                               hasTransactionInProgress: true,
                                                               name: "Bitcoin token",
                                                               fiatBalance: "5 USD",
                                                               balance: "10 BTCA",
                                                               secondaryBalance: "19 BTC",
                                                               secondaryFiatBalance: "10 USD",
                                                               secondaryName: "Bitcoin"),
                            tokenViewModels: tokens)
                    .padding(.horizontal, 16)
            }
        }
    }
}

