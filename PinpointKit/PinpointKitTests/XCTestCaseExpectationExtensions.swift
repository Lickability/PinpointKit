//
//  XCTestCaseExpectationExtensions.swift
//  PinpointKit
//
//  Created by Andrew Harrison on 8/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    /**
     Creates a default expectation for the current function.
     
     - parameter description: The description for the expectation. By default this will be the name of the function.
     
     - returns: A new XCTestExpectation with the given description.
     */
    func defaultExpectation(description: String = #function) -> XCTestExpectation {
        return expectationWithDescription(description)
    }
}
