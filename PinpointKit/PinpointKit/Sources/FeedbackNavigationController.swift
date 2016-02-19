//
//  FeedbackNavigationController.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

public class FeedbackNavigationController: UINavigationController, FeedbackCollector {
    /// The root view controller used to collect feedback.
    let feedbackViewController: FeedbackViewController
    
    public var configuration: Configuration? {
        get {
            return feedbackViewController.configuration
        }
        set {
            feedbackViewController.configuration = newValue
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
    
    override init(navigationBarClass: AnyClass? = nil, toolbarClass: AnyClass? = nil) {
        feedbackViewController = FeedbackViewController()
        
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
        self.viewControllers = [feedbackViewController]
    }
        
    @available(*, unavailable)
    override init(rootViewController: UIViewController) {
        fatalError("init(rootViewController:) is not supported. Use init() or init(navigationBarClass:, toolbarClass:)")
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
