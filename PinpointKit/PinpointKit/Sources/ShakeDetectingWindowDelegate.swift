//
//  ShakeDetectingWindowDelegate.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 4/16/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

public protocol ShakeDetectingWindowDelegate: class {
    func shakeDetectingWindowDidDetectShake(shakeDetectingWindow: ShakeDetectingWindow)
}
