//
//  FeedbackNavigationController.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class FeedbackNavigationController: UINavigationController, FeedbackCollector {
    
    /// The root view controller used to collect feedback.
    let feedbackViewController: FeedbackViewController
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        feedbackViewController = FeedbackViewController()
        
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
        self.viewControllers = [feedbackViewController]
    }
    
    convenience init () {
        self.init(navigationBarClass: nil, toolbarClass: nil)
    }
    
    override init(rootViewController: UIViewController) {
        fatalError("init(rootViewController:) is not supported. Use init() or init(navigationBarClass:, toolbarClass:)")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
