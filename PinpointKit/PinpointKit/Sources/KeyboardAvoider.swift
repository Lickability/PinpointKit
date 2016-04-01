//
//  KeyboardAvoider.swift
//  Pinpoint
//
//  Created by Brian Capps on 4/24/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

public final class KeyboardAvoider {
    public var viewsToAvoidKeyboard: [UIView] = []
    public var triggerViews: [UIView] = []
    public let window: UIWindow?
    
    private var originalConstraintConstants: [NSLayoutConstraint: CGFloat] = [:]
    
    public init(window: UIWindow?) {
        self.window = window
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyboardAvoider.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        let frameEndValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let animationDurationValue = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue
        
        if let frameEndValue = frameEndValue {
            let keyboardEndFrame = frameEndValue.CGRectValue()
            
            let animationDurationNumber = animationDurationValue as? NSNumber
            let animationDuration = animationDurationNumber.map { $0.doubleValue } ?? 0.0
            
            var difference: CGFloat = 0
            
            for triggerView in triggerViews {
                let triggerViewFrameInWindow = triggerView.superview?.convertRect(triggerView.frame, toView: window) ?? CGRectZero
                let intersectsKeyboard = CGRectIntersectsRect(triggerViewFrameInWindow, keyboardEndFrame)
                
                let triggerKeyboardDifference = intersectsKeyboard ? CGRectGetMaxY(triggerViewFrameInWindow) - CGRectGetMinY(keyboardEndFrame) : 0
                difference = max(difference, triggerKeyboardDifference)
            }
            
            // If the keyboard is going to or below 0, we're dismissing.
            let isDismissing = window.map { CGRectGetMinY(keyboardEndFrame) >= CGRectGetMaxY($0.bounds) } ?? false
            
            // This will be animated because this notification is called from within an animation block.
            for avoidingView in self.viewsToAvoidKeyboard {
                let constraints = avoidingView.superview?.constraints ?? []
                
                self.updateAndStoreConstraints(constraints, onView: avoidingView, withDifference: difference, isDismissing: isDismissing)
                
                avoidingView.superview?.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(animationDuration, animations: {}, completion: { (completed) in
                if isDismissing {
                    self.originalConstraintConstants.removeAll(keepCapacity: false)
                }
            })
        }
    }
    
    private func updateAndStoreConstraints(constraints: [AnyObject], onView view: UIView, withDifference difference: CGFloat, isDismissing: Bool) {
        let typedContraints = constraints.filter { $0 is NSLayoutConstraint }.map { $0 as! NSLayoutConstraint }
        
        for constraint in typedContraints {
            let originalConstant = self.originalConstraintConstants[constraint]
            
            if let originalConstant = originalConstant where isDismissing {
                constraint.constant = originalConstant
                self.originalConstraintConstants.removeValueForKey(constraint)
                
            } else if !isDismissing && firstOrSecondItemForConstraint(constraint, isEqualToView: view) {
                // Only replace contraints that don't already exist.
                if originalConstant == nil {
                    self.originalConstraintConstants[constraint] = constraint.constant
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
