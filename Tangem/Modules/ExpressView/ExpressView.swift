//
//  ExpressView.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct ExpressView: View {
    @ObservedObject private var viewModel: ExpressViewModel

    init(viewModel: ExpressViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Colors.Background.tertiary.edgesIgnoringSafeArea(.all)

            GroupedScrollView(spacing: 14) {
                swappingViews

                providerSection

                feeSection

                informationSection

                legalView

                MainButton(
                    title: viewModel.mainButtonState.title,
                    icon: viewModel.mainButtonState.icon,
                    isLoading: viewModel.mainButtonIsLoading,
                    isDisabled: !viewModel.mainButtonIsEnabled,
                    action: viewModel.didTapMainButton
                )
            }
            .scrollDismissesKeyboardCompat(true)
        }
        .navigationBarTitle(Text(Localization.commonSwap), displayMode: .inline)
        .alert(item: $viewModel.alert) { $0.alert }
        // For animate button below informationSection
        .animation(.easeInOut, value: viewModel.providerState?.id)
        .animation(.default, value: viewModel.notificationInputs)
    }

    @ViewBuilder
    private var swappingViews: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 14) {
                GroupedSection(viewModel.sendCurrencyViewModel) {
                    SendCurrencyView(viewModel: $0, decimalValue: $viewModel.sendDecimalValue)
                        .maxAmountAction(viewModel.isMaxAmountButtonHidden ? nil : viewModel.userDidTapMaxAmount)
                        .didTapChangeCurrency(viewModel.userDidTapChangeSourceButton)
                }
                .interSectionPadding(12)
                .interItemSpacing(10)
                .verticalPadding(0)
                .backgroundColor(Colors.Background.action)

                GroupedSection(viewModel.receiveCurrencyViewModel) {
                    ReceiveCurrencyView(viewModel: $0)
                        .didTapChangeCurrency(viewModel.userDidTapChangeDestinationButton)
                        .didTapPriceChangePercent(viewModel.userDidTapPriceChangeInfoButton)
                }
                .interSectionPadding(12)
                .interItemSpacing(10)
                .verticalPadding(0)
                .backgroundColor(Colors.Background.action)
            }

            swappingButton
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var swappingButton: some View {
        Button(action: viewModel.userDidTapSwapSwappingItemsButton) {
            if viewModel.isSwapButtonLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Colors.Icon.informative))
            } else {
                Assets.swappingIcon.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(viewModel.isSwapButtonDisabled ? Colors.Icon.inactive : Colors.Icon.primary1)
            }
        }
        .disabled(viewModel.isSwapButtonLoading || viewModel.isSwapButtonDisabled)
        .frame(width: 44, height: 44)
        .background(Colors.Background.primary)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Colors.Stroke.primary, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var informationSection: some View {
        ForEach(viewModel.notificationInputs) {
            NotificationView(input: $0)
                .setButtonsLoadingState(to: viewModel.isSwapButtonLoading)
                .transition(.notificationTransition)
                .background(Colors.Background.action)
        }
    }

    @ViewBuilder
    private var feeSection: some View {
        GroupedSection(viewModel.expressFeeRowViewModel) {
            ExpressFeeRowView(viewModel: $0)
        }
        .backgroundColor(Colors.Background.action)
        .interSectionPadding(12)
        .interItemSpacing(10)
        .verticalPadding(0)
    }

    @ViewBuilder
    private var providerSection: some View {
        GroupedSection(viewModel.providerState) { state in
            switch state {
            case .loading:
                LoadingProvidersRow()
            case .loaded(let data):
                ProviderRowView(viewModel: data)
            }
        }
        .backgroundColor(Colors.Background.action)
        .interSectionPadding(12)
        .verticalPadding(0)
    }

    @ViewBuilder
    private var legalView: some View {
        if let legalText = viewModel.legalText {
            if #available(iOS 15, *) {
                Text(AttributedString(legalText))
                    .font(Fonts.Regular.footnote)
                    .multilineTextAlignment(.center)
            } else {
                GeometryReader { proxy in
                    VStack(spacing: .zero) {
                        Spacer()
                            .layoutPriority(1)

                        // AttributedTextView(UILabel) doesn't tappable on iOS 14
                        AttributedTextView(legalText, textAlignment: .center, maxLayoutWidth: proxy.size.width)
                    }
                }
            }
        }
    }
}

/*
 struct ExpressView_Preview: PreviewProvider {
     static let viewModel = ExpressViewModel(
         initialWallet: .mock,
         swappingInteractor: .init(
             swappingManager: SwappingManagerMock(),
             userTokensManager: UserTokensManagerMock(),
             currencyMapper: CurrencyMapper(),
             blockchainNetwork: PreviewCard.ethereum.blockchainNetwork!
         ),
         swappingDestinationService: SwappingDestinationServiceMock(),
         tokenIconURLBuilder: TokenIconURLBuilder(),
         transactionSender: TransactionSenderMock(),
         fiatRatesProvider: FiatRatesProviderMock(),
         feeFormatter: FeeFormatterMock(),
         coordinator: ExpressCoordinator()
     )

     static var previews: some View {
         NavigationView {
             ExpressView(viewModel: viewModel)
         }
     }
 }
 */
