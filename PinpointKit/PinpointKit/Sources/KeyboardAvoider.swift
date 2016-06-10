//
//  KeyboardAvoider.swift
//  Pinpoint
//
//  Created by Brian Capps on 4/24/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// A class that handles the adjustment of specified auto-layout views upon the appearance of the keyboard.
final class KeyboardAvoider {
    /// The views to be adjusted when the keyboard appears.
    var viewsToAvoidKeyboard: [UIView] = []
    
    /// Views that trigger the appearance of the keyboard.
    var triggerViews: [UIView] = []
    
    private let window: UIWindow
    
    private var originalConstraintConstants: [NSLayoutConstraint: CGFloat] = [:]
    
    init(window: UIWindow) {
        self.window = window
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardAvoider.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        let frameEndValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let animationDurationValue = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue
        
        guard let keyboardEndFrame = frameEndValue?.CGRectValue() else { return }
        
        let animationDurationNumber = animationDurationValue as? NSNumber
        let animationDuration = animationDurationNumber?.doubleValue ?? 0.0
        
        var difference: CGFloat = 0
        
        for triggerView in triggerViews {
            let triggerViewFrameInWindow = triggerView.superview?.convertRect(triggerView.frame, toView: window) ?? CGRect.zero
            let intersectsKeyboard = triggerViewFrameInWindow.intersects(keyboardEndFrame)
            
            let triggerKeyboardDifference = intersectsKeyboard ? triggerViewFrameInWindow.maxY - keyboardEndFrame.minY : 0
            difference = max(difference, triggerKeyboardDifference)
        }
        
        // If the keyboard is going to or below 0, we're dismissing.
        let isDismissing = keyboardEndFrame.minY >= window.bounds.maxY
        
        // This will be animated because this notification is called from within an animation block.
        for avoidingView in viewsToAvoidKeyboard {
            let constraints = avoidingView.superview?.constraints ?? []
            
            updateAndStoreConstraints(constraints, onView: avoidingView, withDifference: difference, isDismissing: isDismissing)
            
            avoidingView.superview?.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(animationDuration, animations: {}) { finished in
            if isDismissing {
                self.originalConstraintConstants.removeAll(keepCapacity: false)
            }
        }
    }
    
    private func updateAndStoreConstraints(constraints: [NSLayoutConstraint], onView view: UIView, withDifference difference: CGFloat, isDismissing: Bool) {
        
        for constraint in constraints {
            let originalConstant = originalConstraintConstants[constraint]
            
            if let originalConstant = originalConstant where isDismissing {
                constraint.constant = originalConstant
                originalConstraintConstants.removeValueForKey(constraint)
                
            } else if !isDismissing && firstOrSecondItemForConstraint(constraint, isEqualToView: view) {
                // Only replace contraints that don't already exist.
                if originalConstant == nil {
                    originalConstraintConstants[constraint] = constraint.constant
                }
                
                if constraint.secondAttribute == .Bottom {
                    constraint.constant += difference
                } else if constraint.secondAttribute == .Top {
                    constraint.constant -= difference
                }
            }
        }
    }
    
    private func firstOrSecondItemForConstraint(constraint: NSLayoutConstraint, isEqualToView view: UIView) -> Bool {
        return constraint.secondItem as? UIView == view || constraint.firstItem as? UIView == view
    }
}
