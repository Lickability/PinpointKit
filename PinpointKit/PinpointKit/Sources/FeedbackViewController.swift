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
    
    var screenshot: UIImage? {
        didSet {
            if isViewLoaded() {
                updateTableHeaderView()
            }
        }
    }
    
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
            updateTableHeaderView()
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
    
    var dataSource: FeedbackTableViewDataSource = FeedbackTableViewDataSource()
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        
        updateTableHeaderView()
    }
    
    // MARK: - FeedbackViewController
    
    func updateTableHeaderView() {
        guard let screenshot = screenshot else { return }
        
        let header = ScreenshotHeaderView()
        header.viewData = ScreenshotHeaderView.ViewData(screenshot: screenshot, hintText: configuration?.interfaceText.feedbackEditHint)
        
        tableView.tableHeaderView = header
        tableView.enableTableHeaderViewDynamicHeight()
    }
    
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
        self.screenshot = screenshot
        viewConroller.showDetailViewController(self, sender: viewConroller)
    }
    
}

extension UITableView {

    /**
     A workaround to make table header views created in nibs able to use their intrinsic content size to size the header. Removes the autoresizing constraints that constrain the height, and instead adds width contraints to the table header view.
     */
    func enableTableHeaderViewDynamicHeight() {
        tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let headerView = tableHeaderView {
            let leadingConstraint = headerView.leadingAnchor.constraintEqualToAnchor(leadingAnchor)
            let trailingContraint = headerView.trailingAnchor.constraintEqualToAnchor(trailingAnchor)
            let topConstraint = headerView.topAnchor.constraintEqualToAnchor(topAnchor)
            let widthConstraint = headerView.widthAnchor.constraintEqualToAnchor(widthAnchor)
            
            NSLayoutConstraint.activateConstraints([leadingConstraint, trailingContraint, topConstraint, widthConstraint])
            
            headerView.layoutIfNeeded()
            tableHeaderView = headerView
        }
        
    }

}