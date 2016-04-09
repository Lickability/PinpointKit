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

    let pinpointKit = PinpointKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("I am a sneaky log. Primary log knows nothing of me.")
        
        view.backgroundColor = UIColor.lightGrayColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
                
        print("Hei")
        
        NSLog("YO")
        
        pinpointKit.show(fromViewController: self)
    }
}

