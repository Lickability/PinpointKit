//
//  SystemLogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A log collector that uses [Apple System Logger](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html) API to retrieve messages logged to the console with `NSLog`.
open class SystemLogCollector: LogCollector {
    
    /**
     The type of logs to collect.
     */
    public enum LoggingType {
        /// Logs from the application target.
        case application
        
        /// Logs from the testing target.
        case testing
    }
    
    private let logger: ASLLogger
    
    public init(loggingType: LoggingType = .application) {
        switch loggingType {
        case .application:
            logger = ASLLogger(bundleIdentifier: Bundle.main.bundleIdentifier ?? "")
        case .testing:
            logger = ASLLogger(senderName: "xctest")
        }
    }
    
    // MARK: - LogCollector
    
    /**
     Retrieves and returns logs as an ordered list of strings.
          
     - returns: Logs as an ordered list of strings, sorted by descending recency.
     */
    open func retrieveLogs() -> [String] {
        return logger.retrieveLogs()
    }
}
