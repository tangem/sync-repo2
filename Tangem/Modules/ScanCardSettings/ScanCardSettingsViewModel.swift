//
//  ScanCardSettingsViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine

final class ScanCardSettingsViewModel: ObservableObject {
    // MARK: ViewState

    // MARK: Dependencies

    private unowned let coordinator: ScanCardSettingsRoutable
    private let cardModel: CardViewModel

    init(
        cardModel: CardViewModel,
        coordinator: ScanCardSettingsRoutable
    ) {
        self.cardModel = cardModel
        self.coordinator = coordinator
    }
}

// MARK: - View Output

extension ScanCardSettingsViewModel {
    func scanCard() {
        checkPin { [weak self] in
            guard let self = self else {
                return
            }

            self.coordinator.openCardSettings(cardModel: self.cardModel)
        }
    }
}

// MARK: - Private

extension ScanCardSettingsViewModel {
    func checkPin(_ completion: @escaping () -> Void) {
        cardModel.checkPin { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                completion()
            case .failure(let error):
                Analytics.logCardSdkError(error.toTangemSdkError(), for: .readPinSettings, card: self.cardModel.cardInfo.card)
            }
        }
    }
}
