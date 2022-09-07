//
//  SingleCardOnboardingStep.swift
//  Tangem
//
//  Created by Andrew Son on 14.09.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

enum SingleCardOnboardingStep: CaseIterable, Equatable {
    case welcome
    case createWallet
    case topup
    case successTopup
    case saveUserWallet
    case success

    var hasProgressStep: Bool {
        switch self {
        case .createWallet, .topup: return true
        case .welcome, .successTopup, .saveUserWallet, .success: return false
        }
    }

    var icon: Image? {
        switch self {
        case .createWallet: return Image("onboarding.create.wallet")
        case .topup: return Image("onboarding.topup")
        case .welcome, .successTopup, .saveUserWallet, .success: return nil
        }
    }

    var iconFont: Font {
        switch self {
        default: return .system(size: 20, weight: .regular)
        }
    }

    var bigCircleBackgroundScale: CGFloat {
        switch self {
        default: return 0.0
        }
    }

    func cardBackgroundOffset(containerSize: CGSize) -> CGSize {
        switch self {
        case .createWallet:
            return .init(width: 0, height: containerSize.height * 0.103)
        case .topup, .successTopup:
            return defaultBackgroundOffset(in: containerSize)
//            let height = 0.112 * containerSize.height
//            return .init(width: 0, height: height)
        default:
            return .zero
        }
    }

    func balanceTextOffset(containerSize: CGSize) -> CGSize {
        switch self {
        case .topup, .successTopup:
            let backgroundOffset = cardBackgroundFrame(containerSize: containerSize)
            return .init(width: backgroundOffset.width, height: backgroundOffset.height + 12)
        default:
            return cardBackgroundOffset(containerSize: containerSize)
        }
    }

    var balanceStackOpacity: Double {
        switch self {
        case .welcome, .createWallet, .saveUserWallet, .success: return 0
        case .topup, .successTopup: return 1
        }
    }

    func cardBackgroundFrame(containerSize: CGSize) -> CGSize {
        switch self {
        case .welcome, .saveUserWallet, .success: return .zero
        case .createWallet:
            let diameter = SingleCardOnboardingCardsLayout.main.frame(for: self, containerSize: containerSize).height * 1.317
            return .init(width: diameter, height: diameter)
        case .topup, .successTopup:
            return defaultBackgroundFrameSize(in: containerSize)
//            let height = 0.61 * containerSize.height
//            return .init(width: containerSize.width * 0.787, height: height)
        }
    }

    func cardBackgroundCornerRadius(containerSize: CGSize) -> CGFloat {
        switch self {
        case .welcome, .saveUserWallet, .success: return 0
        case .createWallet: return cardBackgroundFrame(containerSize: containerSize).height / 2
        case .topup, .successTopup: return 8
        }
    }
}

extension SingleCardOnboardingStep: SuccessStep { }

extension SingleCardOnboardingStep: OnboardingMessagesProvider {
    var title: LocalizedStringKey {
        switch self {
        case .welcome: return WelcomeStep.welcome.title
        case .createWallet: return "onboarding_create_title"
        case .topup: return "onboarding_topup_title"
            #warning("l10n")
        case .saveUserWallet: return "Would you like to keep wallet on this device?"
        case .successTopup: return "onboarding_confetti_title"
        case .success: return successTitle
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .welcome: return WelcomeStep.welcome.subtitle
        case .createWallet: return "onboarding_create_subtitle"
        case .topup: return "onboarding_topup_subtitle"
            #warning("l10n")
        case .saveUserWallet: return "Save your Wallet feature allows you to use your wallet with biometric auth without tapping your card to the phone to gain access"
        case .successTopup: return "onboarding_confetti_subtitle"
        case .success: return "onboarding_confetti_subtitle"
        }
    }

    var titleLineLimit: Int? {
        switch self {
        case .saveUserWallet:
            return nil
        default:
            return 1
        }
    }
    var messagesOffset: CGSize {
        return .zero
//        switch self {
//        case .success: return successMessagesOffset
//        default: return .zero
        //       }
    }
}

extension SingleCardOnboardingStep: OnboardingButtonsInfoProvider {
    var mainButtonTitle: LocalizedStringKey {
        switch self {
        case .createWallet: return "onboarding_button_create_wallet"
        case .topup: return "onboarding_button_buy_crypto"
        case .successTopup: return "common_continue"
        case .welcome: return WelcomeStep.welcome.mainButtonTitle
            #warning("l10n")
        case .saveUserWallet: return "Allow to link wallet"
        case .success: return successButtonTitle
        }
    }

    var isSupplementButtonVisible: Bool {
        switch self {
        case .welcome, .topup: return true
        case .successTopup, .success, .createWallet, .saveUserWallet: return false
        }
    }

    var supplementButtonTitle: LocalizedStringKey {
        switch self {
        case .welcome: return WelcomeStep.welcome.supplementButtonTitle
        case .createWallet: return "onboarding_button_how_it_works"
        case .topup: return "onboarding_button_show_address_qr"
        case .successTopup, .saveUserWallet, .success: return ""
        }
    }

    var checkmarkText: LocalizedStringKey? {
        return nil
    }

    var infoText: LocalizedStringKey? {
        switch self {
        case .saveUserWallet:
            #warning("l10n")
            return "Keep notice, making a transaction with your funds will still require card tapping"
        default:
            return nil
        }
    }
}

extension SingleCardOnboardingStep: OnboardingProgressStepIndicatable {
    var isOnboardingFinished: Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }

    var successCircleOpacity: Double {
        self == .success ? 1.0 : 0.0
    }

    var successCircleState: OnboardingCircleButton.State {
        switch self {
        case .success: return .doneCheckmark
        default: return .blank
        }
    }
}

extension SingleCardOnboardingStep: OnboardingInitialStepInfo {
    static var initialStep: SingleCardOnboardingStep { .welcome }
}

extension SingleCardOnboardingStep: OnboardingTopupBalanceLayoutCalculator { }

