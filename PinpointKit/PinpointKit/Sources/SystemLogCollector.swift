//
//  SystemLogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A log collector that uses [Apple System Logger](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html) API to retrieve messages logged to the console with `NSLog`.
public class SystemLogCollector: LogCollector {
    
    /**
     The type of logs to collect.
     */
    public enum LoggingType {
        /// Logs from the application target.
        case Application
        
        /// Logs from the testing target.
        case Testing
    }
    
    private let logger: ASLLogger
    
    public init(loggingType: LoggingType = .Application) {
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
