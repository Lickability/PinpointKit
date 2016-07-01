//
//  AppDelegate.swift
//  PinpointKitExample
//
//  Created by Paul Rehkugler on 2/7/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PinpointKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let pinpointKit = PinpointKit(feedbackRecipients: ["feedback@example.com"])
    lazy var window: UIWindow? = ShakeDetectingWindow(frame: UIScreen.mainScreen().bounds, delegate: self.pinpointKit)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSLog("Initial test log for the system logger.")
        return true
    }
}
