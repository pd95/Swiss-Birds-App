//
//  Logger.swift
//  Swiss-Birds
//
//  Created by Philipp on 24.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import os.log

@available(macOS, introduced: 10.15, deprecated: 11.0, message: "Not needed for macOS 11 and above. Replace with os.Logger")
@available(iOS, introduced: 13.0, deprecated: 14.0, message: "Not needed for iOS 14 and above. Replace with os.Logger")
struct Logger {
    let logObject: OSLog

    init(subsystem: String, category: String) {
        logObject = OSLog(subsystem: subsystem, category: category)
    }

    func log(level: OSLogType, _ message: String) {
        os_log("%{public}@", log: logObject, type: level, message)
    }

    func log(_ message: String) {
        log(level: .default, message)
    }

    func debug(_ message: String) {
        log(level: .debug, message)
    }

    func info(_ message: String) {
        log(level: .info, message)
    }

    func error(_ message: String) {
        log(level: .error, message)
    }

    func fault(_ message: String) {
        log(level: .fault, message)
    }
}
