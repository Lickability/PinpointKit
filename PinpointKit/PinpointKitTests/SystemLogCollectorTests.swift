//
//  SystemLogCollectorTests.swift
//  PinpointKit
//
//  Created by Andrew Harrison on 8/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import XCTest
@testable import PinpointKit

class SystemLogCollectorTests: XCTestCase {
    
    func testLogCollectorCollectsLogs() {
        let testString =  "TestLog"
        let sut = SystemLogCollector(loggingType: .Testing)
        
        NSLog(testString)
        NSLog(testString)
        NSLog(testString)

        let logs = sut.retrieveLogs()
        
        guard let firstLog = logs.first else { return XCTFail("There should be at least 1 log.") }
        
        XCTAssertEqual(logs.count, 3)
        XCTAssertTrue(firstLog.containsString(testString))
    }
    
    func testLogCollectorHasNoLogsInitially() {
        let sut = SystemLogCollector(loggingType: .Testing)
        
        let logs = sut.retrieveLogs()
        
        XCTAssertEqual(logs.count, 0)
    }
}
