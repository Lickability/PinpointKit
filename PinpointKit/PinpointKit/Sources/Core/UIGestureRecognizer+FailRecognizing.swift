//
//  UIGestureRecognizer+FailRecognizing.swift
//  PinpointKit
//
//  Created by Kenneth Parker Ackerson on 1/24/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// Extends UIGestureRecognizer to force a failure to recognize the gesture.
extension UIGestureRecognizer {
    
    /**
     Function that forces a gesture recognizer to fail
     */
    func failRecognizing() {
        if !isEnabled {
            return
        }
        
        // Disabling and enabling causes recognizing to fail.
        isEnabled = false
        isEnabled = true
    }
}
