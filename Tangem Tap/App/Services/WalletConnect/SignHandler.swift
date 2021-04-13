//
//  SignHandler.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 02.04.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import WalletConnectSwift

protocol WalletConnectHandler: class {
    var server: Server { get }
    func assertAddress(_ address: String) -> Bool
}

protocol SignHandler: WalletConnectHandler {
    func askToSign(request: Request, address: String, message: String, dataToSign: Data)
}

protocol WCSendTxHandler: WalletConnectHandler {
    func askToMakeTx(request: Request, ethTx: EthTransaction)
}
