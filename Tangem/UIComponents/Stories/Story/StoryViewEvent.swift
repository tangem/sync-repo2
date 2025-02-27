//
//  StoryViewEvent.swift
//  TangemApp
//
//  Created by Aleksei Lobankov on 30.01.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

// TODO: @alobankov, move to TangemUI once resources generation moved to TangemUI
enum StoryViewEvent {
    case viewDidAppear
    case viewDidDisappear

    case viewInteractionPaused
    case viewInteractionResumed

    case longTapPressed
    case longTapEnded

    case tappedForward
    case tappedBackward

    case closeButtonTapped

    case willTransitionBackFromOtherStory
}
