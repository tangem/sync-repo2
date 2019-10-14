//
//  SingleCommandtask.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 03/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
public final class SingleCommandTask<T: CommandSerializer>: Task<CompletionResult<T.CommandResponse, TaskError>> {

    private let commandSerializer: T
    
    public init(_ commandSerializer: T) {
        self.commandSerializer = commandSerializer
    }
    
    override public func run(with environment: CardEnvironment, completion: @escaping (CompletionResult<T.CommandResponse, TaskError>) -> Void) {
         sendCommand(commandSerializer, completion: completion)
    }
}
