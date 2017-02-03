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
        let testString = "TestLog"
        let systemLogCollector = SystemLogCollector(loggingType: .testing)
        
        NSLog(testString)
        NSLog(testString)
        NSLog(testString)
        
        let expectation = defaultExpectation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            
            let systemLogs = systemLogCollector?.retrieveLogs()
            
            guard let logs = systemLogs, let firstLog = logs.first else { return XCTFail("There should be at least 1 log.") }
            
            XCTAssertEqual(logs.count, 3)
            XCTAssertTrue(firstLog.contains(testString))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLogCollectorCollecsLogInOrder() {
        let testString1 = "First"
        let testString2 = "Second"
        let testString3 = "Third"
        
        let systemLogCollector = SystemLogCollector(loggingType: .testing)
        
        NSLog(testString1)
        NSLog(testString2)
        NSLog(testString3)
        
        let expectation = defaultExpectation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            let systemLogs = systemLogCollector?.retrieveLogs()
            
            guard let logs = systemLogs, logs.count == 3 else { return XCTFail("Count should be 3.") }
            
            let firstLog = logs[0]
            let secondLog = logs[1]
            let thirdLog = logs[2]
            
            XCTAssertEqual(logs.count, 3)
            XCTAssertTrue(firstLog.contains(testString1))
            XCTAssertTrue(secondLog.contains(testString2))
            XCTAssertTrue(thirdLog.contains(testString3))
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLogCollectorDoesNotCollectPreviousLogs() {
        NSLog("Hey")
        NSLog("I'm a log!")

        let systemLogCollector = SystemLogCollector(loggingType: .testing)
        
        XCTAssertEqual(systemLogCollector?.retrieveLogs().count, 0)
    }
    
    func testLogCollectorHasNoLogsInitially() {
        let systemLogCollector = SystemLogCollector(loggingType: .testing)
        
        let logs = systemLogCollector?.retrieveLogs()
        
        XCTAssertEqual(logs?.count, 0)
    }
}
