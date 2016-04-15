//
//  SystemLogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

public class SystemLogCollector: LogCollector {
    
    private let logger = ASLLogger()
    
    public init() { }
    
    public func retrieveLogs() -> [String] {
        return logger.retrieveLogs()
    }
}
