//
//  SystemLogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A log collector that uses [Apple System Logger](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html) API to retrieve messages logged to the console with `NSLog`.
public class SystemLogCollector: LogCollector {
    
    private let logger = ASLLogger()
    
    public init() { }
    
    // MARK: - LogCollector
    
    /**
     Retrieves and returns logs as an ordered list of strings.
          
     - returns: Logs as an ordered list of strings, sorted by descending recency.
     */
    public func retrieveLogs() -> [String] {
        return logger.retrieveLogs()
    }
}
