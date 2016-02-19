//
//  FeedbackViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class FeedbackViewController: UITableViewController, FeedbackCollector {
    weak var feedbackDelegate: FeedbackCollectorDelegate?
    var configuration: Configuration? {
        didSet {
            title = configuration?.interfaceText.feedbackCollectorTitle
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: configuration?.interfaceText.feedbackSendButtonTitle, style: .Done, target: self, action: "sendButtonTapped")
            
            let cancelBarButtonItem: UIBarButtonItem
            let cancelAction: Selector = "cancelButtonTapped"
            if let cancelButtonTitle = configuration?.interfaceText.feedbackCancelButtonTitle {
                cancelBarButtonItem = UIBarButtonItem(title: cancelButtonTitle, style: .Plain, target: self, action: cancelAction)
            }
            else {
                cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: cancelAction)
            }
            navigationItem.leftBarButtonItem = cancelBarButtonItem
            
            view.tintColor = configuration?.appearance.tintColor
        }
    }
    
    required init() {
        super.init(style: .Grouped)
    }
    
    @available(*, unavailable)
    override init(style: UITableViewStyle) {
        super.init(style: .Grouped)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - FeedbackViewController
    
    func sendButtonTapped() {
        
        //let feedback = Feedback()
        //feedbackDelegate?.feedbackCollector(self, didCollectFeedback: )
    }
    
    func cancelButtonTapped() {
        // TODO: http://stackoverflow.com/questions/25742944/whats-the-programmatic-opposite-of-showviewcontrollersender
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - FeedbackCollector
    
    func collectFeedbackWithScreenshot(screenshot: UIImage, fromViewController viewConroller: UIViewController) {
        viewConroller.showDetailViewController(self, sender: viewConroller)
    }
    
}
