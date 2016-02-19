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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(title: "Test", message: nil, preferredStyle: .Alert)
        presentViewController(alert, animated: true) { () -> Void in
            let image = Screenshotter.takeScreenshot()
            print(image)
        }
                
//        pinpointKit.show(fromViewController: self)
    }
}

