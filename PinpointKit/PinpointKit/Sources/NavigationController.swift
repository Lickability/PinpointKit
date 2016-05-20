//
//  NavigationController.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

extension UIViewController {
    var customNavigationController: NavigationController? {
        return navigationController as? NavigationController
    }
}

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
    
    func setNavigationBarBackgroundImageColor(color: UIColor, separatorAlpha: CGFloat) {
        var alpha: CGFloat = 0
        color.getRed(nil, green: nil, blue: nil, alpha: &alpha)
                
        if alpha >= 1.0 {
            navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        } else {
            func imageFromColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
                let rect = CGRectMake(0.0, 0.0, size.width, size.height);
                UIGraphicsBeginImageContext(rect.size);
                let context = UIGraphicsGetCurrentContext();
                
                CGContextSetFillColorWithColor(context, color.CGColor);
                CGContextFillRect(context, rect);
                
                let image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                return image;
            }
            navigationBar.setBackgroundImage(imageFromColor(color), forBarMetrics: .Default)
        }
    }
    
}
