//
//  SingleCommandtask.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 03/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
public class SingleCommandTask<TCommandSerializer>: Task where TCommandSerializer: CommandSerializer {
    public typealias TaskResult = TCommandSerializer.CommandResponse
    
    public var cardReader: CardReader?
    public var delegate: CardManagerDelegate?
    
    private let commandSerializer: TCommandSerializer
    
    public init(_ commandSerializer: TCommandSerializer) {
        self.commandSerializer = commandSerializer
    }
    
    public func run(with environment: CardEnvironment, completion: @escaping (CompletionResult<TCommandSerializer.CommandResponse>, CardEnvironment?) -> Void) {
        sendCommand(commandSerializer, environment: environment, completion: completion)
    }
}
