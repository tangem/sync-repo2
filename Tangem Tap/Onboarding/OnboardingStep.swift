//
//  OnboardingStep.swift
//  Tangem Tap
//
//  Created by Andrew Son on 14.09.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

enum OnboardingSteps {
    case singleWallet([SingleCardOnboardingStep]), twins([TwinsOnboardingStep]), wallet
    
    var needOnboarding: Bool {
        switch self {
        case .singleWallet(let steps):
            return steps.count > 0
        case .twins(let steps):
            return steps.count > 0
        case .wallet:
             return false
        }
    }
}

typealias OnboardingStep = OnboardingProgressStepIndicatable & OnboardingMessagesProvider & OnboardingButtonsInfoProvider

protocol OnboardingMessagesProvider {
    var title: LocalizedStringKey { get }
    var subtitle: LocalizedStringKey { get }
}

protocol OnboardingButtonsInfoProvider {
    var mainButtonTitle: LocalizedStringKey { get }
    var supplementButtonTitle: LocalizedStringKey { get }
    var isSupplementButtonVisible: Bool { get }
    var isContainSupplementButton: Bool { get }
}
