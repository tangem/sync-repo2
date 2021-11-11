//
//  ScanCardObserver.swift
//  Tangem
//
//  Created by Andrew Son on 20/02/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation

class FailedCardScanTracker: EmailDataCollector {
    
    weak var logger: Logger!
    
    var dataForEmail: String {
        "----------\n" + DeviceInfoProvider.info()
    }
    
    var attachment: Data? {
        logger.scanLogFileData
    }
    
    var shouldDisplayAlert: Bool {
        numberOfFailedAttempts >= 2
    }
    
    private var numberOfFailedAttempts: Int = 0
    
    func resetCounter() {
        numberOfFailedAttempts = 0
    }
    
    func recordFailure() {
        numberOfFailedAttempts += 1
    }
}
