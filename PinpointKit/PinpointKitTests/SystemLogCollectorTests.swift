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
