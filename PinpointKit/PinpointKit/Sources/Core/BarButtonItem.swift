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
     - parameter title:  The bar button item’s title.
     - parameter font:   The font of the bar button item’s title.
     - parameter action: The bar button item’s action.
     */
    convenience init(doneButtonWithTarget target: AnyObject?, title: String, font: UIFont, action: Selector) {
        self.init(title: title, style: .done, target: target, action: action)
        
        setTitleTextAttributes([NSAttributedStringKey.font: font], for: UIControlState())
    }
}
