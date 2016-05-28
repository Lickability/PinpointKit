//
//  ViewController.swift
//  PinpointKitExample
//
//  Created by Paul Rehkugler on 2/7/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PinpointKit

final class ViewController: UIViewController {
    
    let pinpointKit = PinpointKit(configuration: Configuration(feedbackRecipients: ["hello@lickability.com"]), delegate: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGrayColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        pinpointKit.show(fromViewController: self)
    }
}
