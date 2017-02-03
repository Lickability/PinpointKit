//
//  Screenshotter.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

/// A class responsible for generating a screenshot image of all windows shown by a `UIApplication` on a given `UIScreen`.
open class Screenshotter {

    /**
     Takes and returns a screenshot of all of an application’s windows displayed on a given screen.
     
     - parameter application: The application to screenshot.
     - parameter screen:      The screen to determine the screenshot size.
     
     - returns: A screenshot as a `UIImage`.
     */
    open static func takeScreenshot(of application: UIApplication = UIApplication.shared, on screen: UIScreen = UIScreen.main) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(screen.bounds.size, true, 0)
        
        application.windows.forEach { window in
            guard window.screen == screen else { return }
            
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            preconditionFailure("`UIGraphicsGetImageFromCurrentImageContext()` should never return `nil` as we satisify the requirements of having a bitmap-based current context created with `UIGraphicsBeginImageContextWithOptions(_:_:_:)`")
        }
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
