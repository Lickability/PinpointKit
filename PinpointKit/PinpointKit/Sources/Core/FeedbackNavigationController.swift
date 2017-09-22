//
//  FeedbackNavigationController.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A `UINavigationController` subclass that has a `FeedbackViewController` as its root view controller. Use this class as a `FeedbackCollector`.
public final class FeedbackNavigationController: UINavigationController, FeedbackCollector {
    
    // MARK: - InterfaceCustomizable
    
    public var interfaceCustomization: InterfaceCustomization? {
        get {
            return feedbackViewController.interfaceCustomization
        }
        set {
            feedbackViewController.interfaceCustomization = newValue
            view.tintColor = interfaceCustomization?.appearance.tintColor
        }
    }
    
    // MARK: - LogSupporting
    
    public var logViewer: LogViewer? {
        get {
            return feedbackViewController.logViewer
        }
        set {
            feedbackViewController.logViewer = newValue
        }
    }
    
    public var logCollector: LogCollector? {
        get {
            return feedbackViewController.logCollector
        }
        set {
            feedbackViewController.logCollector = newValue
        }
    }
    
    // MARK: - FeedbackCollector
    
    public var editor: Editor? {
        get {
            return feedbackViewController.editor
        }
        set {
            feedbackViewController.editor = newValue
        }
    }
    
    public var feedbackConfiguration: FeedbackConfiguration? {
        get {
            return feedbackViewController.feedbackConfiguration
        }
        set {
            feedbackViewController.feedbackConfiguration = newValue
        }
    }
    
    public var feedbackDelegate: FeedbackCollectorDelegate? {
        get {
            return feedbackViewController.feedbackDelegate
        }
        set {
            feedbackViewController.feedbackDelegate = newValue
        }
    }
    
    // MARK: - FeedbackNavigationController

    /// The root view controller used to collect feedback.
    let feedbackViewController: FeedbackViewController
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        feedbackViewController = FeedbackViewController()
        
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
     
        commonInitialization()
    }
    
    public convenience init() {
        self.init(navigationBarClass: nil, toolbarClass: nil)
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        feedbackViewController = FeedbackViewController()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    override init(rootViewController: UIViewController) {
        fatalError("init(rootViewController:) is not supported. Use init() or init(navigationBarClass:, toolbarClass:)")
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - FeedbackNavigationController
    
    private func commonInitialization() {
        viewControllers = [feedbackViewController]
    }

    // MARK: - FeedbackCollector
    
    public func collectFeedback(with screenshot: UIImage, from viewController: UIViewController) {
        guard presentingViewController == nil else {
            NSLog("Unable to present FeedbackNavigationController because it is already being presetned")
            return
        }
        
        feedbackViewController.screenshot = screenshot
        feedbackViewController.annotatedScreenshot = screenshot

        viewController.present(self, animated: true, completion: nil)
    }
}
