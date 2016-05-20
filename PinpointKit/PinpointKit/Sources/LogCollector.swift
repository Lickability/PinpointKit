//
//  LogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A behavior protocol that describes an object that collects logs.
public protocol LogCollector {
    
    /**
     Retrieves and returns logs as an ordered list of strings.
     
     - parameter fromOffsetSinceNow: The offset, in seconds, from the current date to retrieve logs. Pass `nil` to retrieve all logs.
     
     - returns: Logs as an ordered list of strings, sorted by descending recency.
     */
    func retrieveLogs() -> [String]
}
