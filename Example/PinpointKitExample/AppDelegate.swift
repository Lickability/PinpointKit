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

    var shakeDetectingWindowDelegate: ShakeDetectingWindowDelegate?

    lazy var window: UIWindow? = {
        let window = ShakeDetectingWindow(frame: UIScreen.mainScreen().bounds)

        let shakeDetectingWindowDelegate = PinpointPresentingShakeDetectingWindowDelegate(pinpointKit: PinpointKit.defaultPinpointKit)
        window.delegate = shakeDetectingWindowDelegate

        self.shakeDetectingWindowDelegate = shakeDetectingWindowDelegate

        return window
    }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSLog("Initial test log for the system logger.")
        
        return true
    }
}

