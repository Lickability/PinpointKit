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
    
    private let pinpointKit = PinpointKit(configuration: Configuration(sender: MySender(), feedbackRecipients: ["feedback@example.com"]))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides the infinite cells footer.
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        pinpointKit.show(fromViewController: self)
    }
}

final class MySender: MailSender {
    
    override func sendFeedback(feedback: Feedback, fromViewController viewController: UIViewController?) {
        var newFeedback = feedback
        newFeedback.title = "hello"
        newFeedback.body = "this is the body of the feedback"
        newFeedback.screenshotFileName = "my feedback"
        newFeedback.additionalInformation = ["user": "mliberatore"]
        newFeedback.logsFileName = "myLogs"
        
        super.sendFeedback(newFeedback, fromViewController: viewController)
    }
}
