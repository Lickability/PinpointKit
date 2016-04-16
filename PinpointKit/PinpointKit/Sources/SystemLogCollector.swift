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
     
     - parameter fromOffsetSinceNow: The offset, in seconds, from the current date to retrieve logs. Pass `nil` to retrieve all logs.
     
     - returns: Logs as an ordered list of strings, sorted by descending recency.
     */
    public func retrieveLogs(fromOffsetSinceNow offset: NSInteger? = nil) -> [String] {
        let loggerOffset = offset ?? NSNotFound
        
        return logger.retrieveLogsFromOffsetSinceNow(loggerOffset)
    }
}
