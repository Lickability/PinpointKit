//
//  ViewController.swift
//  PinpointKitExample
//
//  Created by Paul Rehkugler on 2/7/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PinpointKit

final class ViewController: UITableViewController {
    
    fileprivate var pinpointKit: PinpointKit?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let feedbackConfiguration = FeedbackConfiguration(recipients: ["feedback@example.com"], presentationStyle: .formSheet)
        let configuration = Configuration(feedbackConfiguration: feedbackConfiguration)
        self.pinpointKit = PinpointKit(configuration: configuration)
        
        // Hides the infinite cells footer.
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pinpointKit?.show(from: self)
    }
}
