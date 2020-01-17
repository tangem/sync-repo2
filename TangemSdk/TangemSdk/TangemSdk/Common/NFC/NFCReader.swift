//
//  NFCReader.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 25/09/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import CoreNFC

@available(iOS 13.0, *)
enum NFCTagWrapper {
    case tag(NFCISO7816Tag)
    case error(NFCReaderError)
}

/// Provides NFC communication between an application and Tangem card.
@available(iOS 13.0, *)
public final class NFCReader: NSObject {
    static let tagTimeout = 18.0
    static let sessionTimeout = 52.0
    static let nfcStuckTimeout = 5.0
    static let retryCount = 10
    private let loggingEnabled = true

    public let enableSessionInvalidateByTimer = true
    
    private let connectedTag = CurrentValueSubject<NFCTagWrapper?,Never>(nil)
    private let readerSessionError = CurrentValueSubject<NFCError?,Never>(nil)
    private var readerSession: NFCTagReaderSession?
    private var disposeBag: [AnyCancellable]?
    private var currentRetryCount = NFCReader.retryCount
    private var requestTimestamp: Date?
    private var cancelled: Bool = false
    
    /// Workaround for session timeout error (60 sec)
    private var sessionTimer: TangemTimer!
    /// Workaround for tag timeout connection error (20 sec)
    private var tagTimer: TangemTimer!
    /// Workaround for nfc stuck
    private var nfcStuckTimer: TangemTimer!
    
    /// Invalidate session before session will close automatically
    @objc private func timerTimeout() {
        guard let session = readerSession,
            session.isReady else { return }
        
        stopSession(errorMessage: Localization.nfcSessionTimeout)
        readerSessionError.send(NFCError.readerError(underlyingError: NFCReaderError(.readerSessionInvalidationErrorSessionTimeout)))
    }
    
    private func stopTimers() {
        TangemTimer.stopTimers([sessionTimer, tagTimer, nfcStuckTimer])
    }
    
    override init() {
        super.init()
        sessionTimer = TangemTimer(timeInterval: NFCReader.sessionTimeout, completion: timerTimeout)
        tagTimer = TangemTimer(timeInterval: NFCReader.tagTimeout, completion: timerTimeout)
        nfcStuckTimer = TangemTimer(timeInterval: NFCReader.nfcStuckTimeout, completion: {[weak self] in
            self?.stopSession()
            self?.readerSessionError.send(NFCError.stuck)
        })
    }
}

@available(iOS 13.0, *)
extension NFCReader: CardReader {
    public var alertMessage: String {
        get { return readerSession?.alertMessage ?? "" }
        set { readerSession?.alertMessage = newValue }
    }
    
    /// Start session and try to connect with tag
    public func startSession() {
        if let existingSession = readerSession, existingSession.isReady { return }
        readerSessionError.send(nil)
        connectedTag.send(nil)
        
        readerSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)!
        readerSession!.alertMessage = Localization.nfcAlertDefault
        readerSession!.begin()
        nfcStuckTimer.start()
    }
    
    public func stopSession(errorMessage: String? = nil) {
        stopTimers()
        readerSessionError.send(nil)
        connectedTag.send(nil)
        if let errorMessage = errorMessage {
            readerSession?.invalidate(errorMessage: errorMessage)
        } else {
            readerSession?.invalidate()
        }
        readerSession = nil
    }
    
    /// Send apdu command to connected tag
    /// - Parameter command: serialized apdu
    /// - Parameter completion: result with ResponseApdu or NFCError otherwise
    public func send(commandApdu: CommandApdu, completion: @escaping (Result<ResponseApdu, NFCError>) -> Void) {
        let sessionSubscription = readerSessionError
            .compactMap { $0 }
            .sink(receiveValue: { [weak self] error in
                completion(.failure(error))
                self?.cancelSubscriptions()
            })

        let tagSubscription = connectedTag
            .compactMap({ $0 })
            .sink(receiveValue: { [weak self] tagWrapper in
                switch tagWrapper {
                case .error(let tagError):
                    completion(.failure(NFCError.readerError(underlyingError: tagError)))
                    self?.cancelSubscriptions()
                case .tag(let tag):
                    let apdu = NFCISO7816APDU(commandApdu)
                    self?.sendCommand(apdu: apdu, to: tag, completion: completion)
                }
            })
        
        disposeBag = [sessionSubscription, tagSubscription]
    }
    
    public func restartPolling() {
        guard let session = readerSession, session.isReady else { return }
        
        readerSessionError.send(nil)
        connectedTag.send(nil)
        tagTimer.stop()
        log("Restart polling")
        session.restartPolling()
    }
    
    private func sendCommand(apdu: NFCISO7816APDU, to tag: NFCISO7816Tag, completion: @escaping (Result<ResponseApdu, NFCError>) -> Void) {
        requestTimestamp = Date()
        tag.sendCommand(apdu: apdu) {[weak self] (data, sw1, sw2, error) in
            guard let self = self,
                let session = self.readerSession,
                session.isReady else {
                    return
            }
            
            guard !self.cancelled else {
                self.log("skip cancelled")
                return
            }

            if error != nil {
                if let requestTimestamp = self.requestTimestamp,
                    requestTimestamp.distance(to: Date()) > 1.0 {
                    self.cancelled = true
                    self.log("invoke restart polling by timestamp")
                    self.restartPolling()
                    return
                }
                
                if self.currentRetryCount > 0 {
                    self.log("invoke restart by retry count")
                    self.currentRetryCount -= 1
                    self.sendCommand(apdu: apdu, to: tag, completion: completion)
                } else {
                    self.log("invoke restart by retry count")
                    self.restartPolling()
                }
                
            } else {
                self.currentRetryCount = NFCReader.retryCount
                let responseApdu = ResponseApdu(data, sw1 ,sw2)
                self.cancelSubscriptions()
                completion(.success(responseApdu))
            }
        }
    }
    
    private func cancelSubscriptions() {
        disposeBag?.forEach{ $0.cancel() }
        disposeBag = nil
    }
    
    private func log(_ message: String) {
        if loggingEnabled {
            print(message)
        }
    }
}

@available(iOS 13.0, *)
extension NFCReader: NFCTagReaderSessionDelegate {
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        nfcStuckTimer.stop()
        sessionTimer.start()
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        cancelled = true
        stopTimers()
        let nfcError = error as! NFCReaderError
        readerSessionError.send(NFCError.readerError(underlyingError: nfcError))
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        currentRetryCount = NFCReader.retryCount
        cancelled = false
        let nfcTag = tags.first!
        if case let .iso7816(tag7816) = nfcTag {
            session.connect(to: nfcTag) {[weak self] error in
                guard error == nil else {
                    session.restartPolling()
                    return
                }
                
                self?.tagTimer.start()
                self?.connectedTag.send(.tag(tag7816))
            }
        }
    }
}
