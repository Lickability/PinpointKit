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
     
     - returns: Logs as an ordered list of strings.
     */
    func retrieveLogs() -> [String]
}
