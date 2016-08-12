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
            guard isViewLoaded else { return }
            
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
            guard isViewLoaded else { return }
            updateTableHeaderView()
        }
    }
    
    /// The annotated screenshot the feedback describes.
    var annotatedScreenshot: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            updateTableHeaderView()
        }
    }
    
    private var dataSource: FeedbackTableViewDataSource? {
        didSet {
            guard isViewLoaded else { return }
            tableView.dataSource = dataSource
        }
    }
    
    private var userEnabledLogCollection = true {
        didSet {
            updateDataSource()
        }
    }
    
    public required init() {
        super.init(style: .grouped)
    }
    
    @available(*, unavailable)
    override init(style: UITableViewStyle) {
        super.init(style: .grouped)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        editor?.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Since this view controller could be reused in another orientation, update the table header view on every appearance to reflect the current orientation sizing.
        updateTableHeaderView()
        updateInterfaceCustomization()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { context in
            // Layout and adjust the height of the table header view by setting the property once more to alert the table view of a layout change.
            self.tableView.tableHeaderView?.layoutIfNeeded()
            self.tableView.tableHeaderView = self.tableView.tableHeaderView
        }, completion: nil)
    }
    
    // MARK: - FeedbackViewController
    
    private func updateDataSource() {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return }
        
        dataSource = FeedbackTableViewDataSource(interfaceCustomization: interfaceCustomization, logSupporting: self, userEnabledLogCollection: userEnabledLogCollection)
    }
    
    private func updateTableHeaderView() {
        guard let screenshot = screenshot, editor = editor else { return }
        let screenshotToDisplay = annotatedScreenshot ?? screenshot
        
        // We must set the screenshot before showing the view controller.
        editor.setScreenshot(screenshot)
        let header = ScreenshotHeaderView()

        header.viewModel = ScreenshotHeaderView.ViewModel(screenshot: screenshotToDisplay, hintText: interfaceCustomization?.interfaceText.feedbackEditHint, hintFont: interfaceCustomization?.appearance.feedbackEditHintFont)
        header.screenshotButtonTapHandler = { [weak self] button in
            let editImageViewController = NavigationController(rootViewController: editor.viewController)
            editImageViewController.view.tintColor = self?.interfaceCustomization?.appearance.tintColor
            self?.present(editImageViewController, animated: true, completion: nil)
        }
        
        tableView.tableHeaderView = header
        tableView.enableTableHeaderViewDynamicHeight()
    }
    
    private func updateInterfaceCustomization() {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return }
        let interfaceText = interfaceCustomization.interfaceText
        let appearance = interfaceCustomization.appearance

        title = interfaceText.feedbackCollectorTitle
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: appearance.navigationTitleFont]
        
        let sendBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackSendButtonTitle, style: .done, target: self, action: #selector(FeedbackViewController.sendButtonTapped))
        sendBarButtonItem.setTitleTextAttributes([NSFontAttributeName: appearance.feedbackSendButtonFont], for: UIControlState())
        navigationItem.rightBarButtonItem = sendBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackBackButtonTitle, style: .plain, target: nil, action: nil)
        backBarButtonItem.setTitleTextAttributes([NSFontAttributeName: appearance.feedbackBackButtonFont], for: UIControlState())
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let cancelBarButtonItem: UIBarButtonItem
        let cancelAction = #selector(FeedbackViewController.cancelButtonTapped)
        if let cancelButtonTitle = interfaceText.feedbackCancelButtonTitle {
            cancelBarButtonItem = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: cancelAction)
        } else {
            cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancelAction)
        }
        
        cancelBarButtonItem.setTitleTextAttributes([NSFontAttributeName: appearance.feedbackCancelButtonFont], for: UIControlState())
        
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = cancelBarButtonItem
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        view.tintColor = appearance.tintColor
        updateTableHeaderView()
        updateDataSource()
    }
    
    @objc private func sendButtonTapped() {
        
        let logs = userEnabledLogCollection ? logCollector?.retrieveLogs() : nil
        
        let feedback: Feedback?
        
        if let screenshot = annotatedScreenshot {
            feedback = Feedback(screenshot: .annotated(image: screenshot), logs: logs, configuration: feedbackConfiguration)
        } else if let screenshot = screenshot {
            feedback = Feedback(screenshot: .original(image: screenshot), logs: logs, configuration: feedbackConfiguration)
        } else {
            feedback = nil
        }
        
        guard let feedbackToSend = feedback else { return assertionFailure("We must have either a screenshot or an edited screenshot!") }
        
        feedbackDelegate?.feedbackCollector(self, didCollect: feedbackToSend)
    }
    
    @objc private func cancelButtonTapped() {
        guard presentingViewController != nil else {
            assertionFailure("Attempting to dismiss `FeedbackViewController` in unexpected presentation context.")
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - FeedbackCollector

extension FeedbackViewController: FeedbackCollector {
    public func collectFeedback(with screenshot: UIImage, from viewController: UIViewController) {
        self.screenshot = screenshot
        annotatedScreenshot = nil
        viewController.showDetailViewController(self, sender: viewController)
    }
}

// MARK: - EditorDelegate

extension FeedbackViewController: EditorDelegate {
    public func editorWillDismiss(_ editor: Editor, with screenshot: UIImage) {
        annotatedScreenshot = screenshot
        updateTableHeaderView()
    }
}

// MARK: - UITableViewDelegate

extension FeedbackViewController {
    public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let logCollector = logCollector else {
            assertionFailure("No log collector exists.")
            return
        }
        
        logViewer?.viewLog(in: logCollector, from: self)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userEnabledLogCollection = !userEnabledLogCollection
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

private extension UITableView {
    
    /**
     A workaround to make table header views created in nibs able to use their intrinsic content size to size the header. Removes the autoresizing constraints that constrain the height, and instead adds width contraints to the table header view.
     */
    func enableTableHeaderViewDynamicHeight() {
        tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let headerView = tableHeaderView {
            let leadingConstraint = headerView.leadingAnchor.constraint(equalTo: leadingAnchor)
            let trailingContraint = headerView.trailingAnchor.constraint(equalTo: trailingAnchor)
            let topConstraint = headerView.topAnchor.constraint(equalTo: topAnchor)
            let widthConstraint = headerView.widthAnchor.constraint(equalTo: widthAnchor)
            
            NSLayoutConstraint.activate([leadingConstraint, trailingContraint, topConstraint, widthConstraint])
            
            headerView.layoutIfNeeded()
            tableHeaderView = headerView
        }
    }
}
