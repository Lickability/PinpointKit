//
//  Screenshotter.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

/// A class responsible for generating a screenshot image of all windows shown by a `UIApplication` on a given `UIScreen`.
public class Screenshotter {

    /**
     Takes and returns a screenshot of all of an `application`’s windows displayed on a given screen.
     
     - parameter screen:      The screen to determine the screenshot size.
     - parameter application: The application to screenshot.
     
     - returns: A screenshot as a `UIImage`.
     */
    public static func takeScreenshot(screen: UIScreen = UIScreen.mainScreen(), application: UIApplication = UIApplication.sharedApplication()) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(screen.bounds.size, true, 0)
        
        application.windows.forEach { window in
            guard window.screen == screen else { return }
            
            window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: false)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
