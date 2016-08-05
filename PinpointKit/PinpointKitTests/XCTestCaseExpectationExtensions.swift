//
//  XCTestCaseExpectationExtensions.swift
//  PinpointKit
//
//  Created by Andrew Harrison on 8/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func defaultExpectation(description: String = #function) -> XCTestExpectation {
        return expectationWithDescription(description)
    }
}
