//
//  DetailsView.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject private var viewModel: DetailsViewModel

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GroupedScrollView(spacing: 24) {
//            walletConnectSection

            userWalletsSection

//            commonSection

            settingsSection

            supportSection

//            legalSection

            environmentSetupSection

            socialNetworks
        }
        .interContentPadding(8)
        .background(Colors.Background.secondary.edgesIgnoringSafeArea(.all))
        .background(
            ScanTroubleshootingView(
                isPresented: $viewModel.showTroubleshootingView,
                tryAgainAction: viewModel.tryAgain,
                requestSupportAction: viewModel.requestSupport,
                openScanCardManualAction: viewModel.openScanCardManual
            )
        )
        .alert(item: $viewModel.alert) { $0.alert }
        .navigationTitle(Localization.detailsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.onAppear)
    }

    // MARK: - Wallet Connect Section

//    @ViewBuilder
//    private var walletConnectSection: some View {
//        GroupedSection(viewModel.walletConnectRowViewModel) {
//            WalletConnectRowView(viewModel: $0)
//        }
//    }

    private var userWalletsSection: some View {
        GroupedSection(viewModel.walletsSectionTypes) { type in
            switch type {
            case .wallet(let viewModel):
                DetailsUserWalletRowView(viewModel: viewModel)
            case .addOrScanNewUserWalletButton(let viewModel):
                DefaultRowView(viewModel: viewModel)
                    .appearance(.accentButton)
            }
        }
    }

    private var settingsSection: some View {
        GroupedSection(viewModel.settingsSectionViewModels) {
            DefaultRowView(viewModel: $0)
        }
    }

    private var supportSection: some View {
        GroupedSection(viewModel.supportSectionModels) {
            DefaultRowView(viewModel: $0)
        }
    }

//    private var commonSection: some View {
//        GroupedSection(viewModel.commonSectionViewModels) {
//            DefaultRowView(viewModel: $0)
//        }
//    }

    private var socialNetworks: some View {
        VStack(alignment: .center, spacing: 16) {
            ForEach(SocialNetwork.list, id: \.hashValue) { networks in
                HStack(spacing: 16) {
                    ForEach(networks) { network in
                        socialNetworkView(network: network)
                    }
                }
            }

            if let applicationInfoFooter = viewModel.applicationInfoFooter {
                Text(applicationInfoFooter)
                    .style(Fonts.Regular.footnote, color: Colors.Text.tertiary)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var environmentSetupSection: some View {
        GroupedSection(viewModel.environmentSetupViewModel) {
            DefaultRowView(viewModel: $0)
        } header: {
            DefaultHeaderView("Setup environment in app")
        }
    }

    private func socialNetworkView(network: SocialNetwork) -> some View {
        Button(action: {
            viewModel.openSocialNetwork(network: network)
        }) {
            network.icon.image
                .resizable()
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsView(
                viewModel: DetailsViewModel(
                    coordinator: DetailsCoordinator()
                )
            )
        }
        .navigationViewStyle(.stack)
    }
}
