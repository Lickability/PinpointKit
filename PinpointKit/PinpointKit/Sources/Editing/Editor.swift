//
//  Editor.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

public protocol Editor {
    func setDelegate(delegate: EditImageViewControllerDelegate)
    
    func setScreenshot(screenshot: UIImage)
    
    func viewController() -> UIViewController
}
