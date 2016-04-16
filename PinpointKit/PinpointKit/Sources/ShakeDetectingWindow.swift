//
//  ShakeDetectingWindow.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 3/18/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

public class ShakeDetectingWindow: UIWindow {

	public weak var delegate: ShakeDetectingWindowDelegate?

	// MARK: - UIResponder
	
	override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
		if motion == .MotionShake {
            guard let delegate = delegate else {
                print("ShakeDetectingWindow - There is no ShakeDetectingWindowDelegate registered to handle this shake.")
                return
            }
            delegate.shakeDetectingWindowDidDetectShake(self)
		}
	}
}
