//
//  StoryAvailabilityService.swift
//  TangemModules
//
//  Created by Aleksei Lobankov on 06.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import struct Combine.AnyPublisher

public protocol StoryAvailabilityService {
    var availableStoriesPublisher: AnyPublisher<Set<TangemStory.ID>, Never> { get }

    func checkStoryAvailability(storyId: TangemStory.ID) -> Bool
    func markStoryAsShown(storyId: TangemStory.ID)
    func markStoryAsUnavailableForCurrentSession(_ storyId: TangemStory.ID)
}
