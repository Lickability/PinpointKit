//
//  FeedbackNavigationController.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A `UINavigationController` subclass that has a `FeedbackViewController` as its root view controller. Use this class as a `FeedbackCollector`.
public class FeedbackNavigationController: UINavigationController, FeedbackCollector {
    /// The root view controller used to collect feedback.
    let feedbackViewController: FeedbackViewController
    
    /// The configuration the feedback view controller uses to set itself up.
    public var configuration: Configuration? {
        get {
            return feedbackViewController.configuration
        }
        set {
            feedbackViewController.configuration = newValue
            view.tintColor = configuration?.appearance.tintColor
        }
    }

    /// A delegate that is informed of significant events in feedback collection.
    public var feedbackDelegate: FeedbackCollectorDelegate? {
        get {
            return feedbackViewController.feedbackDelegate
        }
        set {
            feedbackViewController.feedbackDelegate = newValue
        }
    }
        
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        feedbackViewController = FeedbackViewController()
        
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
     
        commonInitialization()
    }
    
    convenience init () {
        self.init(navigationBarClass: nil, toolbarClass: nil)
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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
    
    public func collectFeedbackWithScreenshot(screenshot: UIImage, fromViewController viewController: UIViewController) {
        feedbackViewController.screenshot = screenshot
        viewController.presentViewController(self, animated: true, completion: nil)
    }
}
