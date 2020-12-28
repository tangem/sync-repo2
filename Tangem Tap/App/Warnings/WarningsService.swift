//
//  WarningsService.swift
//  Tangem Tap
//
//  Created by Andrew Son on 22/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

protocol WarningsConfigurator: class {
    func setupWarnings(for card: Card)
}

protocol WarningsManager: class {
    func warnings(for location: WarningsLocation) -> WarningsContainer
    func addWarning(for event: WarningEvent)
    func hideWarning(_ warning: TapWarning)
}

class WarningsService {
    
    private var mainWarnings: WarningsContainer = .init()
    private var sendWarnings: WarningsContainer = .init()
    
    private let remoteWarningProvider: RemoteWarningProvider
    
    init(remoteWarningProvider: RemoteWarningProvider) {
        self.remoteWarningProvider = remoteWarningProvider
    }
    
    private func warningsForMain(for card: Card) -> WarningsContainer {
        let container = WarningsContainer()
        
        addDevCardWarningIfNeeded(in: container, for: card)
        addOldCardWarning(in: container, for: card)
        addOldCardWarningIfNeeded(in: container, for: card)
        
        let remoteWarnings = self.remoteWarnings(for: card, location: .main)
        container.add(remoteWarnings)
        
        return container
    }
    
    private func warningsForSend(for card: Card) -> WarningsContainer {
        .init()
    }
    
    private func remoteWarnings(for card: Card, location: WarningsLocation) -> [TapWarning] {
        let remoteWarnings = remoteWarningProvider.warnings
        let mainRemoteWarnings = remoteWarnings.filter { $0.location.contains { $0 == location } }
        let cardRemoteWarnings = mainRemoteWarnings.filter {
            $0.blockchains == nil ||
            $0.blockchains?.contains { $0.lowercased() == (card.cardData?.blockchainName ?? "").lowercased() } ?? false
        }
        return cardRemoteWarnings
    }
    
    private func addDevCardWarningIfNeeded(in container: WarningsContainer, for card: Card) {
        guard card.firmwareVersion?.type == .sdk else {
            return
        }
        
        container.add(TapWarning(title: "common_warning".localized, message: "alert_developer_card".localized, priority: .critical, type: .permanent))
    }
    
    private func addOldCardWarning(in container: WarningsContainer, for card: Card) {
        if card.canSign { return }
        
        container.add(TapWarning(title: "common_warning".localized, message: "alert_old_card".localized, priority: .info, type: .permanent))
    }
    
    private func addOldCardWarningIfNeeded(in container: WarningsContainer, for card: Card) {
        guard let fw = card.firmwareVersionValue else {
            return
        }
        
        guard fw < 2.28 else { //old cards
            return
        }
        
        guard NfcUtils.isPoorNfcQualityDevice else { //old phone
            return
        }
        
        container.add(TapWarning(title: "common_warning".localized, message: "alert_old_device_this_card".localized, priority: .info, type: .permanent))
    }
    
}

extension WarningsService: WarningsManager {
    func warnings(for location: WarningsLocation) -> WarningsContainer {
        switch location {
        case .main:
            return mainWarnings
        case .send:
            return sendWarnings
        }
    }
    
    func addWarning(for event: WarningEvent) {
        let warning = event.warning
        if event.locationsToDisplay.contains(.main) {
            mainWarnings.add(warning)
        }
        if event.locationsToDisplay.contains(.send) {
            sendWarnings.add(warning)
        }
    }
    
    func hideWarning(_ warning: TapWarning) {
        mainWarnings.remove(warning)
        sendWarnings.remove(warning)
    }
}

extension WarningsService: WarningsConfigurator {
    func setupWarnings(for card: Card) {
        mainWarnings = warningsForMain(for: card)
        sendWarnings = warningsForSend(for: card)
    }
}
