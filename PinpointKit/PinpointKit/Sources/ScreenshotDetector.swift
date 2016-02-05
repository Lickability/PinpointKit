//
//  ScreenshotDetector.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

final class ScreenshotDetector: NSObject {
    private let notificationCenter: NSNotificationCenter
    private let application: UIApplication

    init(pinpointKit: PinpointKit, notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter(), application: UIApplication = UIApplication.sharedApplication()) {
        self.notificationCenter = notificationCenter
        self.application = application
        
        super.init()
        
        notificationCenter.addObserver(self, selector: "userTookScreenshot:", name: UIApplicationUserDidTakeScreenshotNotification, object: application)
    }
    
    private func userTookScreenshot(notification: NSNotification) {
    
    }

}
