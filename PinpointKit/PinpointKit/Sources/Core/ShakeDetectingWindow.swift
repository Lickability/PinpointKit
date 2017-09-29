//
//  ShakeDetectingWindow.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 3/18/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// `ShakeDetectingWindow` is a `UIWindow` subclass that notifies a `ShakeDetectingWindowDelegate` any time a shake motion event occurs.
open class ShakeDetectingWindow: UIWindow {

    /// A `ShakeDetectingWindowDelegate` to notify when a shake motion event occurs.
	open weak var delegate: ShakeDetectingWindowDelegate?

    /**
     Initializes a `ShakeDetectingWindow`.

     - parameter frame:    The frame rectangle for the view.
     - parameter delegate: An object to notify when a shake motion event occurs.
     */
	required public init(frame: CGRect, delegate: ShakeDetectingWindowDelegate) {
        self.delegate = delegate
        super.init(frame: frame)
	}

	// MARK: - UIWindow
    
	required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
	}
	
	// MARK: - UIResponder
    
    override open func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            guard let delegate = delegate else {
                NSLog(#file + "- There is no ShakeDetectingWindowDelegate registered to handle this shake.")
                return
            }
            
            delegate.shakeDetectingWindowDidDetectShake(self)
        }
    }
}
