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

    override init(nibName: String?, bundle nibBundle: Bundle?) {
        super.init(nibName: nibName, bundle: nibBundle)
        delegate = self
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
        modalPresentationStyle = .fullScreen // Necessary for proper transition rotation.
        modalPresentationCapturesStatusBarAppearance = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController
    
    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .unknown
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
