//
//  Publisher+Async.swift
//  Tangem
//
//  Created by Sergey Balashov on 07.03.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Combine
import Foundation

public extension Publisher {
    func async() async throws -> Output {
        var didSendValue = false
        var didSendContinuation = false
        let criticalSection = Lock(isRecursive: false)
        let cancellableWrapper = CancellableWrapper()

        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                // This check is necessary in case this code runs after the task was
                // cancelled. In which case we want to bail right away.
                guard !Task.isCancelled else {
                    continuation.resume(throwing: CancellationError())
                    return
                }

                cancellableWrapper.value = first()
                    .handleEvents(receiveCancel: {
                        // We don't get a cancel error when cancelling a publisher, so we need
                        // to handle if the publisher was cancelled from the
                        // `withTaskCancellationHandler` here.
                        criticalSection {
                            if !didSendContinuation {
                                didSendContinuation = true
                                continuation.resume(throwing: CancellationError())
                            }
                        }
                    }).sink { completion in
                        criticalSection {
                            var errorToSend: Error? = nil
                            if case .failure(let error) = completion {
                                errorToSend = error
                            } else if !didSendValue {
                                errorToSend = AsyncError.valueWasNotEmittedBeforeCompletion
                            }

                            if let errorToSend, !didSendContinuation {
                                didSendContinuation = true
                                continuation.resume(throwing: errorToSend)
                            }
                        }
                    } receiveValue: { value in
                        criticalSection {
                            didSendValue = true
                            didSendContinuation = true
                            continuation.resume(returning: value)
                        }
                    }
            }
        } onCancel: {
            cancellableWrapper.cancel()
        }
    }
}

enum AsyncError: Error {
    case valueWasNotEmittedBeforeCompletion
}

/// Closures in `withTaskCancellationHandler(handler:operation:)` may be called on different threads,
/// this wrapper provides required synchronization.
private final class CancellableWrapper {
    var value: Cancellable? {
        get { criticalSection { innerCancellable } }
        set { criticalSection { innerCancellable = newValue } }
    }

    private var innerCancellable: Cancellable?
    private let criticalSection = Lock(isRecursive: false)

    func cancel() {
        criticalSection { innerCancellable?.cancel() }
    }
}
