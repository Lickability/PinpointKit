//
//  FeedbackViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A `UITableViewController` that conforms to `FeedbackCollector` in order to display an interface that allows the user to see, change, and send feedback.
public final class FeedbackViewController: UITableViewController, FeedbackCollector, EditImageViewControllerDelegate {
    
    // MARK: - InterfaceCustomization
    
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
    
    // MARK: - FeedbackViewControllevar configurationdelegate that is informed of significant events in feedback collection.
    public weak var feedbackDelegate: FeedbackCollectorDelegate?
    
    /// The screenshot the feedback describes.
    public var screenshot: UIImage? {
        didSet {
            guard isViewLoaded() else { return }
            updateTableHeaderView()
        }
    }
    
    /**
     This is storage for after a user annotates an image and we get a callback for this.
     
     The reason we can not just use the `screenshot` property to do so is because:
     
     1. Editors have to have the same backing image for the whole time they are in memory
     2. Semantically the `screenshot` property is the original screenshot and could be confusing
     
     For #1, we could just set the editing image back on the editor every time (since we reset the 
     editor's screenshot everytime `updateTableHeaderView` is called) - however this would mean the annotations
     would not be editable (movable or scalable). 
     
     This is the best solution I could think of considering we have to keep the `Editor` in
     memory for the lifetime that PinpointKit is alive (for now).
    */
    private var editedScreenshot: UIImage?
    
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
        editor?.setDelegate(self)
        updateInterfaceCustomization()
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ context in
            // Layout and adjust the height of the table header view by setting the property once more to alert the table view of a layout change.
            self.tableView.tableHeaderView?.layoutIfNeeded()
            self.tableView.tableHeaderView = self.tableView.tableHeaderView
            }, completion: nil)
    }
    
    // MARK: - FeedbackViewController
    
    private func updateDataSource() {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return }
        
        dataSource = FeedbackTableViewDataSource(interfaceCustomization: interfaceCustomization, logSupporting:self, userEnabledLogCollection: userEnabledLogCollection)
    }
    
    /**
     Determines the correct screenshot for 
     
     1. Display in the feedback header
     2. To _actually send_ when we want to send the feedback.
     
     - returns: An optional image that is the most appropriate for use.
     */
    private func usableScreenShot() -> UIImage? {
        guard let screenshot = screenshot else { return nil }
        
        return editedScreenshot ?? screenshot
    }
    
    private func updateTableHeaderView() {
        guard let screenshot = screenshot, editor = editor else { return }
        
        // We must set the screenshot before showing the view controller.
        editor.setScreenshot(screenshot)
        let screenshotToDisplay = usableScreenShot()
        let header = ScreenshotHeaderView()

        header.viewModel = ScreenshotHeaderView.ViewModel(screenshot: screenshotToDisplay!, hintText: interfaceCustomization?.interfaceText.feedbackEditHint)
        header.screenshotButtonTapHandler = { [weak self] button in
            let editImageViewController = NavigationController(rootViewController: editor.viewController())
            self?.presentViewController(editImageViewController, animated: true, completion: nil)
        }
        
        tableView.tableHeaderView = header
        tableView.enableTableHeaderViewDynamicHeight()
    }
    
    private func updateInterfaceCustomization() {
        title = interfaceCustomization?.interfaceText.feedbackCollectorTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: interfaceCustomization?.interfaceText.feedbackSendButtonTitle, style: .Done, target: self, action: #selector(FeedbackViewController.sendButtonTapped))
        
        let cancelBarButtonItem: UIBarButtonItem
        let cancelAction = #selector(FeedbackViewController.cancelButtonTapped)
        if let cancelButtonTitle = interfaceCustomization?.interfaceText.feedbackCancelButtonTitle {
            cancelBarButtonItem = UIBarButtonItem(title: cancelButtonTitle, style: .Plain, target: self, action: cancelAction)
        } else {
            cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: cancelAction)
        }
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        view.tintColor = interfaceCustomization?.appearance.tintColor
        updateTableHeaderView()
        updateDataSource()
    }
    
    @objc private func sendButtonTapped() {
        guard let screenshot = usableScreenShot() else { assertionFailure("We must have either a screenshot or an edited screenshot!"); return }
        
        // TODO: Handle annotated screenshot.
        // TODO: Only send logs if `userEnabledLogCollection` is `true.
        
        let feedback = Feedback(screenshot: Feedback.ScreenshotType.Original(image: screenshot))
        feedbackDelegate?.feedbackCollector(self, didCollectFeedback: feedback)
    }
    
    @objc private func cancelButtonTapped() {
        // TODO: http://stackoverflow.com/questions/25742944/whats-the-programmatic-opposite-of-showviewcontrollersender
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - FeedbackCollector
    
    public func collectFeedbackWithScreenshot(screenshot: UIImage, fromViewController viewController: UIViewController) {
        self.screenshot = screenshot
        viewController.showDetailViewController(self, sender: viewController)
    }
    
    public func didTapCloseButton(screenshot: UIImage) {
        self.editedScreenshot = screenshot
        updateTableHeaderView()
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
}

private extension UITableView {
    
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
