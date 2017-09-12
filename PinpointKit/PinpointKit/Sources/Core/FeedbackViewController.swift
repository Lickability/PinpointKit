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
            updateDataSource()
        }
    }
    
    /// The annotated screenshot the feedback describes.
    var annotatedScreenshot: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            updateDataSource()
        }
    }
    
    private var dataSource: FeedbackTableViewDataSource? {
        didSet {
            guard isViewLoaded else { return }
            tableView.dataSource = dataSource
        }
    }
    
    fileprivate var userEnabledLogCollection = true {
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
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Helps to prevent extra spacing from appearing at the top of the table.
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: .leastNormalMagnitude))
        tableView.sectionHeaderHeight = .leastNormalMagnitude
        
        editor?.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: appearance.navigationTitleFont]
        
        let sendBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackSendButtonTitle, style: .done, target: self, action: #selector(FeedbackViewController.sendButtonTapped))
        sendBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: appearance.feedbackSendButtonFont], for: UIControlState())
        navigationItem.rightBarButtonItem = sendBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackBackButtonTitle, style: .plain, target: nil, action: nil)
        backBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: appearance.feedbackBackButtonFont], for: UIControlState())
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let cancelBarButtonItem: UIBarButtonItem
        let cancelAction = #selector(FeedbackViewController.cancelButtonTapped)
        if let cancelButtonTitle = interfaceText.feedbackCancelButtonTitle {
            cancelBarButtonItem = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: cancelAction)
        } else {
            cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancelAction)
        }
        
        cancelBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: appearance.feedbackCancelButtonFont], for: UIControlState())
        
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
    
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Only leave space under the last section.
        if section == tableView.numberOfSections - 1 {
            return tableView.sectionFooterHeight
        }
        
        return .leastNormalMagnitude
    }
}

// MARK: - FeedbackTableViewDataSourceDelegate

extension FeedbackViewController: FeedbackTableViewDataSourceDelegate {
    
    func feedbackTableViewDataSource(feedbackTableViewDataSource: FeedbackTableViewDataSource, didTapScreenshot screenshot: UIImage) {
        guard let editor = editor else { return }
        guard let screenshotToEdit = self.screenshot else { return }
        
        editor.screenshot = screenshotToEdit
        
        let editImageViewController = NavigationController(rootViewController: editor.viewController)
        editImageViewController.view.tintColor = interfaceCustomization?.appearance.tintColor
        present(editImageViewController, animated: true, completion: nil)
    }
}
