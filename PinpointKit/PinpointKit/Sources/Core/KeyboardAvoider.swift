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
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardAvoider.keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        let frameEndValue = (notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let animationDurationValue = (notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue
        
        guard let keyboardEndFrame = frameEndValue?.cgRectValue else { return }
        
        let animationDurationNumber = animationDurationValue as? NSNumber
        let animationDuration = animationDurationNumber?.doubleValue ?? 0.0
        
        var difference: CGFloat = 0
        
        for triggerView in triggerViews {
            let triggerViewFrameInWindow = triggerView.superview?.convert(triggerView.frame, to: window) ?? CGRect.zero
            let intersectsKeyboard = triggerViewFrameInWindow.intersects(keyboardEndFrame)
            
            let triggerKeyboardDifference = intersectsKeyboard ? triggerViewFrameInWindow.maxY - keyboardEndFrame.minY : 0
            difference = max(difference, triggerKeyboardDifference)
        }
        
        // If the keyboard is going to or below 0, we're dismissing.
        let isDismissing = keyboardEndFrame.minY >= window.bounds.maxY
        
        // This will be animated because this notification is called from within an animation block.
        for avoidingView in viewsToAvoidKeyboard {
            let constraints = avoidingView.superview?.constraints ?? []
            
            updateAndStore(constraints, on: avoidingView, withDifference: difference, isDismissing: isDismissing)
            
            avoidingView.superview?.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: animationDuration, animations: {}, completion: { _ in
            if isDismissing {
                self.originalConstraintConstants.removeAll(keepingCapacity: false)
            }
        })
    }
    
    private func updateAndStore(_ constraints: [NSLayoutConstraint], on view: UIView, withDifference difference: CGFloat, isDismissing: Bool) {
        
        for constraint in constraints {
            let originalConstant = originalConstraintConstants[constraint]
            
            if let originalConstant = originalConstant, isDismissing {
                constraint.constant = originalConstant
                originalConstraintConstants.removeValue(forKey: constraint)
                
            } else if !isDismissing && firstOrSecondItem(forConstraint: constraint, isEqualTo: view) {
                // Only replace contraints that don't already exist.
                if originalConstant == nil {
                    originalConstraintConstants[constraint] = constraint.constant
                }
                
                if constraint.secondAttribute == .bottom {
                    constraint.constant += difference
                } else if constraint.secondAttribute == .top {
                    constraint.constant -= difference
                }
            }
        }
    }
    
    private func firstOrSecondItem(forConstraint constraint: NSLayoutConstraint, isEqualTo view: UIView) -> Bool {
        return constraint.secondItem as? UIView == view || constraint.firstItem as? UIView == view
    }
}
