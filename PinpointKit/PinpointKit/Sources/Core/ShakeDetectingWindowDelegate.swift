//
//  ShakeDetectingWindowDelegate.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 4/16/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

/// A `ShakeDetectingWindowDelegate` is the receiver of callbacks from `ShakeDetectingWindow` when a shake motion event occurs.
public protocol ShakeDetectingWindowDelegate: class {

    /**
     Notifies the receiver that a shake motion event has been detected by the `ShakeDetectingWindow`.

     - parameter shakeDetectingWindow: The `ShakeDetectingWindow` in which the shake motion event occurred.
     */
    func shakeDetectingWindowDidDetectShake(_ shakeDetectingWindow: ShakeDetectingWindow)
}
