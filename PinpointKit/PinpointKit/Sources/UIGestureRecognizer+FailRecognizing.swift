//
//  UIGestureRecognizer+FailRecognizing.swift
//  PinpointKit
//
//  Created by Kenneth Parker Ackerson on 1/24/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

extension UIGestureRecognizer {
    
    /**
     Function that forces a gesture recognizer to fail
     */
    func failRecognizing() {
        if !enabled {
            return
        }
        
        // Disabling and enabling causes recognizing to fail.
        enabled = false
        enabled = true
    }
}
