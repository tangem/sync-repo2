//
//  LegacyFileLogger.swift
//  TangemApp
//
//  Created by Sergey Balashov on 12.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct LegacyFileLogger {
    // Remove the legacy log file
    func remove() {
        do {
            let fileName = "scanLogs.txt"
            let fileManager = FileManager.default
            let logFileURL = fileManager
                .urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName)

            if fileManager.fileExists(atPath: logFileURL.path) {
                try fileManager.removeItem(at: logFileURL)
            }
        } catch {
            AppLogger.error(error: error)
        }
    }
}
