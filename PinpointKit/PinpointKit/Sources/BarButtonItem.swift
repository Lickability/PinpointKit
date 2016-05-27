//
//  BarButtonItem.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/22/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    convenience init(doneButtonWithTarget target: AnyObject?, font: UIFont, action: Selector) {
        self.init(barButtonSystemItem: .Done, target: target, action: action)
        
        setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
    }
}
