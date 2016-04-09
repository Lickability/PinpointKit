//
//  SystemLogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

public class SystemLogCollector: LogCollector {
    
    public init() {
        
    }
    
    public func initializeLogging() {
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let fileName = "blipptiy.log"
        let logFilePath = documentsDirectory?.URLByAppendingPathComponent(fileName)
        let cPath = logFilePath?.path?.cStringUsingEncoding(NSASCIIStringEncoding)
        
        freopen(cPath!, "w+", stderr)
    }
}
