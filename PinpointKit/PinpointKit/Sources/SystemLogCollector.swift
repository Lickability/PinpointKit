//
//  SystemLogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/**
 The type of logs to collect.
 
 - Application: Logs from the application target.
 - Testing:     Logs from the testing target.
 */
public enum ASLLoggingType {
    case Application
    case Testing
}

/// A log collector that uses [Apple System Logger](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html) API to retrieve messages logged to the console with `NSLog`.
public class SystemLogCollector: LogCollector {
    
    private let logger: ASLLogger
    
    public init(loggingType: ASLLoggingType = .Application) {
        switch loggingType {
        case .Application:
            logger = ASLLogger(bundleIdentifier: NSBundle.mainBundle().bundleIdentifier ?? "")
        case .Testing:
            logger = ASLLogger(senderName: "xctest")
        }
    }
    
    // MARK: - LogCollector
    
    /**
     Retrieves and returns logs as an ordered list of strings.
          
     - returns: Logs as an ordered list of strings, sorted by descending recency.
     */
    public func retrieveLogs() -> [String] {
        return logger.retrieveLogs()
    }
}
