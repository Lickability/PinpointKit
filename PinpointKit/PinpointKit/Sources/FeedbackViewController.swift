//
//  FeedbackViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A `UITableViewController` that conforms to `FeedbackCollector` in order to display an interface that allows the user to see, change, and send feedback.
public final class FeedbackViewController: UITableViewController {
    
    // MARK: - InterfaceCustomizable
    
    public var interfaceCustomization: InterfaceCustomization? {
        didSet {
            guard isViewLoaded() else { return }
            
            updateInterfaceCustomization()
        }
    }
    
    // MARK: - LogSupporting
    
    public var logViewer: LogViewer?
    public var logCollector: LogCollector?
    public var editor: Editor?
    
    // MARK: - FeedbackCollector
    
    public weak var feedbackDelegate: FeedbackCollectorDelegate?
    public var feedbackConfiguration: FeedbackConfiguration?
    
    // MARK: - FeedbackViewController
    
    /// The screenshot the feedback describes.
    public var screenshot: UIImage? {
        didSet {
            guard isViewLoaded() else { return }
            updateDataSource()
        }
    }
    
    /// The annotated screenshot the feedback describes.
    var annotatedScreenshot: UIImage? {
        didSet {
            guard isViewLoaded() else { return }
            updateDataSource()
        }
    }
    
    private var dataSource: FeedbackTableViewDataSource? {
        didSet {
            guard isViewLoaded() else { return }
            tableView.dataSource = dataSource
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
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Helps to prevent extra spacing from appearing at the top of the table.
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: .min))
        tableView.sectionHeaderHeight = .min
        
        editor?.delegate = self
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateInterfaceCustomization()
    }
    
    // MARK: - FeedbackViewController
    
    private func updateDataSource() {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return }
        guard let screenshot = screenshot else { assertionFailure(); return }
        let screenshotToDisplay = annotatedScreenshot ?? screenshot
        
        dataSource = FeedbackTableViewDataSource(interfaceCustomization: interfaceCustomization, screenshot: screenshotToDisplay, logSupporting: self, userEnabledLogCollection: userEnabledLogCollection, delegate: self)
    }
    
    private func updateInterfaceCustomization() {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return }
        let interfaceText = interfaceCustomization.interfaceText
        let appearance = interfaceCustomization.appearance

        title = interfaceText.feedbackCollectorTitle
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: appearance.navigationTitleFont]
        
        let sendBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackSendButtonTitle, style: .Done, target: self, action: #selector(FeedbackViewController.sendButtonTapped))
        sendBarButtonItem.setTitleTextAttributes([NSFontAttributeName: appearance.feedbackSendButtonFont], forState: .Normal)
        navigationItem.rightBarButtonItem = sendBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackBackButtonTitle, style: .Plain, target: nil, action: nil)
        backBarButtonItem.setTitleTextAttributes([NSFontAttributeName: appearance.feedbackBackButtonFont], forState: .Normal)
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let cancelBarButtonItem: UIBarButtonItem
        let cancelAction = #selector(FeedbackViewController.cancelButtonTapped)
        if let cancelButtonTitle = interfaceText.feedbackCancelButtonTitle {
            cancelBarButtonItem = UIBarButtonItem(title: cancelButtonTitle, style: .Plain, target: self, action: cancelAction)
        } else {
            cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: cancelAction)
        }
        
        cancelBarButtonItem.setTitleTextAttributes([NSFontAttributeName: appearance.feedbackCancelButtonFont], forState: .Normal)
        
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = cancelBarButtonItem
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        view.tintColor = appearance.tintColor
        updateDataSource()
    }
    
    @objc private func sendButtonTapped() {
        
        guard let feedbackConfiguration = feedbackConfiguration else {
            assertionFailure("You must set `feedbackConfiguration` before attempting to send feedback.")
            return
        }
        
        let logs = userEnabledLogCollection ? logCollector?.retrieveLogs() : nil
        
        let feedback: Feedback?
        
        if let screenshot = annotatedScreenshot {
            feedback = Feedback(screenshot: .Annotated(image: screenshot), logs: logs, configuration: feedbackConfiguration)
        } else if let screenshot = screenshot {
            feedback = Feedback(screenshot: .Original(image: screenshot), logs: logs, configuration: feedbackConfiguration)
        } else {
            feedback = nil
        }
        
        guard let feedbackToSend = feedback else { return assertionFailure("We must have either a screenshot or an edited screenshot!") }
        
        feedbackDelegate?.feedbackCollector(self, didCollectFeedback: feedbackToSend)
    }
    
    @objc private func cancelButtonTapped() {
        guard presentingViewController != nil else {
            assertionFailure("Attempting to dismiss `FeedbackViewController` in unexpected presentation context.")
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - FeedbackCollector

extension FeedbackViewController: FeedbackCollector {
    public func collectFeedbackWithScreenshot(screenshot: UIImage, fromViewController viewController: UIViewController) {
        self.screenshot = screenshot
        annotatedScreenshot = nil
        viewController.showDetailViewController(self, sender: viewController)
    }
}

// MARK: - EditorDelegate

extension FeedbackViewController: EditorDelegate {
    public func editorWillDismiss(editor: Editor, screenshot: UIImage) {
        annotatedScreenshot = screenshot
    }
}

// MARK: - UITableViewDelegate

extension FeedbackViewController {
    public override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        guard let logCollector = logCollector else {
            assertionFailure("No log collector exists.")
            return
        }
        
        logViewer?.viewLog(logCollector, fromViewController: self)
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        userEnabledLogCollection = !userEnabledLogCollection
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Only leave space under the last section.
        if section == tableView.numberOfSections - 1 {
            return tableView.sectionFooterHeight
        }
        
        return .min
    }
}

// MARK: - FeedbackTableViewDataSourceDelegate

extension FeedbackViewController: FeedbackTableViewDataSourceDelegate {

    func feedbackTableViewDataSource(feedbackTableViewDataSource: FeedbackTableViewDataSource, didTapScreenshot screenshot: UIImage) {
        guard let editor = editor else { return }
        guard let screenshotToEdit = self.screenshot else { return }
        
        editor.setScreenshot(screenshotToEdit)
        
        let editImageViewController = NavigationController(rootViewController: editor.viewController)
        editImageViewController.view.tintColor = interfaceCustomization?.appearance.tintColor
        presentViewController(editImageViewController, animated: true, completion: nil)
    }
}
