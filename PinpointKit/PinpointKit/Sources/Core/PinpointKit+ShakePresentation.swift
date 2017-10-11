//
//  PinpointKit+ShakePresentation.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 4/16/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

/// Extends `PinpointKit` to present itself on the application's root view controller as the result of a shake event.
extension PinpointKit: ShakeDetectingWindowDelegate {
    
    // MARK: - ShakeDetectingWindowDelegate
    
    public func shakeDetectingWindowDidDetectShake(_ shakeDetectingWindow: ShakeDetectingWindow) {
        guard let viewController = shakeDetectingWindow.rootViewController?.pinpointTopModalViewController() else {
            NSLog("PinpointPresentingShakeDetectingWindowDelegate couldn't find a root view controller to present on.")
            return
        }
        
        show(from: viewController)
    }
}

private extension UIViewController {
    
    func pinpointTopModalViewController() -> UIViewController {
        var topViewController: UIViewController = self
        
        while topViewController.presentedViewController != nil {
            guard let presentedViewController = topViewController.presentedViewController else { break }
            
            topViewController = presentedViewController
        }
        
        return topViewController
    }
}
