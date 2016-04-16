//
//  ShakeDetectingWindow.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 3/18/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class ShakeDetectingWindow: UIWindow {
	
	weak var delegate: ShakeDetectingWindowDelegate?
	
	required init(
        frame: CGRect,
        delegate: ShakeDetectingWindowDelegate = PinpointPresentingShakeDetectingWindowDelegate(pinpointKit: PinpointKit.defaultPinpointKit))
    {
        self.delegate = delegate
        super.init(frame: frame)
	}

	// MARK: - UIWindow
	
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - UIResponder
	
	override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
		if motion == .MotionShake {
            delegate?.shakeDetectingWindowDidDetectShake(self)
		}
	}
}
