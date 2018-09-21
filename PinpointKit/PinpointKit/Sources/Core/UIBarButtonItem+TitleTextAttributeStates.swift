//
//  UIBarButtonItem+TitleTextAttributeStates.swift
//  PinpointKit
//
//  Created by Michael Liberatore on 5/4/18.
//

import UIKit

/// Extends `UIBarButtonItem` to fix an issue with title text attribute propagation.
extension UIBarButtonItem {
    
    /// Sets the specified title text attributes for `.normal`, `.highlighted`, `.disabled`, and `.focused` control states.
    ///
    /// - Parameter titleTextAttributes: A dictionary containing key-value pairs for text attributes.
    /// - Note: It should be enough to specify `.normal` and have the attributes propagate, but a bug (radar: 35221407) was introduced in iOS 11 which broke this functionality.
    func setTitleTextAttributesForAllStates(_ titleTextAttributes: [NSAttributedString.Key: Any]?) {
        
        // Note: Specifying them all in one option set also does not work correctly. The `.normal` state will revert to default text attributes.
        setTitleTextAttributes(titleTextAttributes, for: [.normal])
        setTitleTextAttributes(titleTextAttributes, for: [.highlighted])
        setTitleTextAttributes(titleTextAttributes, for: [.disabled])
        setTitleTextAttributes(titleTextAttributes, for: [.focused])
    }
}
