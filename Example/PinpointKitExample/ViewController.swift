//
//  ViewController.swift
//  PinpointKitExample
//
//  Created by Paul Rehkugler on 2/7/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PinpointKit

class ViewController: UIViewController {
    var pinpointKit: PinpointKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinpointKit = PinpointKit()
        
        view.backgroundColor = UIColor.lightGrayColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //PinpointKit.defaultPinpointKit.show(fromViewController: self)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.pinpointKit = nil
        }
    }
}

