//
//  NavigationController.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The custom navigation controller that PinpointKit uses to wrap the `FeedbackViewController`.
final class NavigationController: UINavigationController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

    // MARK: - Initializers

    override init(nibName: String?, bundle nibBundle: NSBundle?) {
        super.init(nibName: nibName, bundle: nibBundle)
        delegate = self
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
        modalPresentationStyle = .FullScreen // Necessary for proper transition rotation.
        modalPresentationCapturesStatusBarAppearance = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController
    
    override func shouldAutorotate() -> Bool {
        return topViewController?.shouldAutorotate() ?? false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations() ?? .All
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation() ?? .Unknown
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return topViewController
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return topViewController
    }
}
