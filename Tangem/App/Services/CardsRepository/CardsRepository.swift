//
//  CardsRepository.swift
//  Tangem
//
//  Created by Alexander Osokin on 11.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol CardsRepository {
    var delegate: CardsRepositoryDelegate? { get set }

    var models: [CardViewModel] { get }

    func scan(with batch: String?, requestBiometrics: Bool, _ completion: @escaping (Result<CardViewModel, Error>) -> Void)
    func scanPublisher(with batch: String?, requestBiometrics: Bool) ->  AnyPublisher<CardViewModel, Error>

    func add(_ cardModels: [CardViewModel])
    func removeModel(with userWalletId: Data)
    func clear()
    func didSwitch(to cardModel: CardViewModel)
}

protocol CardsRepositoryDelegate: AnyObject {
    func showTOS(at url: URL, _ completion: @escaping (Bool) -> Void)
}

private struct CardsRepositoryKey: InjectionKey {
    static var currentValue: CardsRepository = CommonCardsRepository()
}

extension InjectedValues {
    var cardsRepository: CardsRepository {
        get { Self[CardsRepositoryKey.self] }
        set { Self[CardsRepositoryKey.self] = newValue }
    }
}

extension CardsRepository {
    func scanPublisher(with batch: String? = nil, requestBiometrics: Bool = false) ->  AnyPublisher<CardViewModel, Error> {
        scanPublisher(with: batch, requestBiometrics: requestBiometrics)
    }

    func add(_ cardModel: CardViewModel) {
        add([cardModel])
    }
}

protocol ScanListener {
    func onScan(cardInfo: CardInfo)
}

enum CardsRepositoryError: Error {
    case noCard
}
