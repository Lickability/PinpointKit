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
    let logger = ASLLogger()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSLog("I am the first log. The only log. The primary log!")
        print("KOOL")
        
        
        NSLog("I am the second log. Death to the primary log!")
        print("no way bro")
        NSLog("\n\nLogger's logs: \n\(logger.retrieveLogs())")
        
        return true
    }
}

