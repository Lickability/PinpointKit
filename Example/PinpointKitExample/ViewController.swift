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
    
    fileprivate let pinpointKit = PinpointKit(feedbackRecipients: ["feedback@example.com"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides the infinite cells footer.
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pinpointKit.show(from: self)
        
        let screenshotType = Feedback.ScreenshotType.original(image: #imageLiteral(resourceName: "liberatore"))
        let preferredImage = screenshotType.preferredImage
        let applicationInformation: Feedback.ApplicationInformation = Feedback.ApplicationInformation(version: nil, build: nil, name: nil, bundleIdentifier: nil, operatingSystemVersion: nil)
        
        let feedbackConfiguration = FeedbackConfiguration(recipients: ["feedback@example.com"])
        
        let feedback = Feedback(screenshot: screenshotType, applicationInformation: applicationInformation, configuration: feedbackConfiguration)
        
        let mimeType = MIMEType.PlainText
        print(mimeType.fileExtension)
        
        // Just to silence warnings of unused variables.
        print(preferredImage)
        print(feedback)
    }
}
