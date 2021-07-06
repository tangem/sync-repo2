//
//  CreateWalletAndReadTask.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 07.04.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

class CreateWalletAndReadTask: CardSessionRunnable {
    func run(in session: CardSession, completion: @escaping CompletionResult<Card>) {
        if let fw = session.environment.card?.firmwareVersion, fw.major < 4 {
            createLegacyWallet(in: session, completion: completion)
        } else {
            createMultiWallet(in: session, completion: completion)
        }
    }

    private func createMultiWallet(in session: CardSession, completion: @escaping CompletionResult<Card>) {
        let createWalletCommand = CreateMultiWalletTask()
        createWalletCommand.run(in: session) { createWalletCompletion in
            switch createWalletCompletion {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                self.scanCard(session: session, completion: completion)
            }
        }
    }

    private func createLegacyWallet(in session: CardSession, completion: @escaping CompletionResult<Card>) {
        guard let card = session.environment.card else {
            completion(.failure(.missingPreflightRead))
            return
        }
        
        guard let supportedCurve = card.supportedCurves.first else {
            completion(.failure(.cardError))
            return
        }
        
        let createWalletCommand = CreateWalletCommand(curve: supportedCurve, isPermanent: card.isPermanentLegacyWallet)
        createWalletCommand.run(in: session) { createWalletCompletion in
            switch createWalletCompletion {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                 self.scanCard(session: session, completion: completion)
            }
        }
    }

    private func scanCard(session: CardSession, completion: @escaping CompletionResult<Card>) {
        let scanTask = PreflightReadTask(readMode: .fullCardRead, cardId: nil)
        scanTask.run(in: session, completion: completion)
    }
}
