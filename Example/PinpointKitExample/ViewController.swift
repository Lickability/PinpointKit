//
//  ViewController.swift
//  PinpointKitExample
//
//  Created by Paul Rehkugler on 2/7/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PinpointKit

final class ViewController: UITableViewController, ScreenshotDetectorDelegate {

    private var screenshotDetector: ScreenshotDetector?
    
    fileprivate let pinpointKit = PinpointKit(feedbackRecipients: ["feedback@example.com"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenshotDetector = ScreenshotDetector(delegate: self)
        
        // Hides the infinite cells footer.
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - ScreenshotDetectorDelegate
    
    func screenshotDetector(_ screenshotDetector: ScreenshotDetector, didDetect screenshot: UIImage) {
        pinpointKit.show(from: self, screenshot: screenshot)
    }
    
    func screenshotDetector(_ screenshotDetector: ScreenshotDetector, didFailWith error: ScreenshotDetector.Error) {
        print(error)
    }
    
}
