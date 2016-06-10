//
//  BarButtonItem.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/22/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    /**
     Convenience initializer for creating a “Done” `UIBarButtonItem` with a specified target, action, and font.
     
     - parameter target: The bar button item’s target.
     - parameter font:   The font of the bar button item’s title.
     - parameter action: The bar button item’s action.
     */
    convenience init(doneButtonWithTarget target: AnyObject?, font: UIFont, action: Selector) {
        self.init(barButtonSystemItem: .Done, target: target, action: action)
        
        setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
    }
}
