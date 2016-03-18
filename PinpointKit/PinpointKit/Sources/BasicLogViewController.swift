//
//  BasicLogViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

public class BasicLogViewController: UIViewController, LogViewer {
    
    override public func viewDidLoad() {
        view.backgroundColor = .lightGrayColor()
    }
    
    // MARK: - LogViewer
    
    public func viewLog(collector: LogCollector, fromViewController viewController: UIViewController) {
        viewController.showDetailViewController(self, sender: viewController)
    }
}

