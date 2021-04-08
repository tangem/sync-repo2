//
//  CreateWalletAndReadTask.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 07.04.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

struct CardResponse: JSONStringConvertible {
    let card: Card
}

class CreateWalletAndReadTask: CardSessionRunnable {
    typealias CommandResponse = CardResponse
    
    func run(in session: CardSession, completion: @escaping CompletionResult<CommandResponse>) {
        if let fw = session.environment.card?.firmwareVersion, fw.major < 4 {
            createLegacyWallet(in: session, completion: completion)
        } else {
            createMultiWallet(in: session, completion: completion)
        }
    }
    
    private func createMultiWallet(in session: CardSession, completion: @escaping CompletionResult<CommandResponse>) {
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
    
    private func createLegacyWallet(in session: CardSession, completion: @escaping CompletionResult<CommandResponse>) {
        let createWalletCommand = CreateWalletCommand(config: nil, walletIndex: 0)
        createWalletCommand.run(in: session) { createWalletCompletion in
            switch createWalletCompletion {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                self.scanCard(session: session, completion: completion)
            }
        }
    }
    
    private func scanCard(session: CardSession, completion: @escaping CompletionResult<CommandResponse>) {
        let scanTask = TapScanTask()
        scanTask.run(in: session) { scanCompletion in
            switch scanCompletion {
            case .failure(let error):
                completion(.failure(error))
            case .success(let scanResponse):
                completion(.success(CardResponse(card: scanResponse.card)))
            }
        }
    }
}
