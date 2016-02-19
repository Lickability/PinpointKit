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
    
    // MARK: - FeedbackCollector
    
    func collectFeedbackFromViewController(viewConroller: UIViewController) {
        viewConroller.showDetailViewController(self, sender: viewConroller)
    }
    
}
