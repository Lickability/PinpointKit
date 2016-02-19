//
//  Screenshotter.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

public class Screenshotter {

    public class func takeScreenshot(screen: UIScreen = UIScreen.mainScreen(), application: UIApplication = UIApplication.sharedApplication()) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(screen.bounds.size, true, 0)
        
        application.windows.forEach { window in
            window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: false)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
