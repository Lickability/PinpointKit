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
	
	required public init(
        frame: CGRect,
        delegate: ShakeDetectingWindowDelegate = PinpointKit.defaultPinpointKit)
    {
        self.delegate = delegate
        super.init(frame: frame)
	}

	// MARK: - UIWindow
	
	@available(*, unavailable)
	required public init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
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
