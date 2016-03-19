//
//  ShakeDetectingWindow.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 3/18/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class ShakeDetectingWindow: UIWindow {
	
	let pinpointKit: PinpointKit
	
	required init(frame: CGRect, pinpointKit: PinpointKit = PinpointKit.defaultPinpointKit) {
		self.pinpointKit = pinpointKit
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
			// TODO: find topmost view controller
			// TODO: uncomment this when #33 is merged
			// pinpointKit.show(fromViewController: self)
		}
	}
}
