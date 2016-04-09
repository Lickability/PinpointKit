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

    var window: UIWindow?
    let logger = SystemLogCollector()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        logger.initializeLogging()
        
        NSLog("I am the first log. The only log. The primary log!")
        
        return true
    }
}

