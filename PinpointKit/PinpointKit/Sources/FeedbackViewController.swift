//
//  FeedbackViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

public class FeedbackViewController: UITableViewController, FeedbackCollector {
    public weak var feedbackDelegate: FeedbackCollectorDelegate?
    
    var screenshot: UIImage? {
        didSet {
            guard isViewLoaded() else { return }
            
            updateTableHeaderView()
        }
    }
    
    public var configuration: Configuration? {
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
            updateDataSource()
        }
    }
    
    private var dataSource: FeedbackTableViewDataSource? {
        didSet {
            if isViewLoaded() {
                tableView.dataSource = dataSource
            }
        }
    }
    
    private var userEnabledLogCollection = true {
        didSet {
            updateDataSource()
        }
    }
    
    public required init() {
        super.init(style: .Grouped)
    }
    
    @available(*, unavailable)
    override init(style: UITableViewStyle) {
        super.init(style: .Grouped)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        updateDataSource()
        updateTableHeaderView()
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ context in
            // Layout and adjust the height of the table header view by setting the property once more to alert the table view of a layout change.
            self.tableView.tableHeaderView?.layoutIfNeeded()
            self.tableView.tableHeaderView = self.tableView.tableHeaderView
        }, completion: nil)
    }
    
    // MARK: - FeedbackViewController
    
    func updateDataSource() {
        guard let configuration = configuration else { assertionFailure(); return }
        
        dataSource = FeedbackTableViewDataSource(configuration: configuration, userEnabledLogCollection: userEnabledLogCollection)
    }
    
    func updateTableHeaderView() {
        guard let screenshot = screenshot else { return }
        
        let header = ScreenshotHeaderView()
        header.viewData = ScreenshotHeaderView.ViewData(screenshot: screenshot, hintText: configuration?.interfaceText.feedbackEditHint)
        
        tableView.tableHeaderView = header
        tableView.enableTableHeaderViewDynamicHeight()
    }
    
    func sendButtonTapped() {
        guard let screenshot = screenshot else { assertionFailure(); return }
        
        // TODO: Handle annotated screenshot.
        // TODO: Only send logs if `userEnabledLogCollection` is `true.
        
        let feedback = Feedback(screenshot: Feedback.ScreenshotType.Original(image: screenshot))
        feedbackDelegate?.feedbackCollector(self, didCollectFeedback: feedback)
    }
    
    func cancelButtonTapped() {
        // TODO: http://stackoverflow.com/questions/25742944/whats-the-programmatic-opposite-of-showviewcontrollersender
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - FeedbackCollector
    
    public func collectFeedbackWithScreenshot(screenshot: UIImage, fromViewController viewController: UIViewController) {
        self.screenshot = screenshot
        viewController.showDetailViewController(self, sender: viewController)
    }
}

// MARK: - UITableViewDelegate
extension FeedbackViewController {
    public override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        guard let logCollector = configuration?.logCollector else {
            assertionFailure("No log collector exists.")
            return
        }
        
        configuration?.logViewer?.viewLog(logCollector, fromViewController: self)
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        userEnabledLogCollection = !userEnabledLogCollection
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
