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
    
    private static let pinpointKit = PinpointKit(feedbackRecipients: ["feedback@example.com"])
    var window: UIWindow? = ShakeDetectingWindow(frame: UIScreen.main.bounds, delegate: AppDelegate.pinpointKit)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSLog("Initial test log for the system logger.")
        return true
    }
}
