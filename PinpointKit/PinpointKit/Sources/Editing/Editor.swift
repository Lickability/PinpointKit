//
//  Editor.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

public protocol Editor {
    weak var delegate: EditImageViewControllerDelegate? { get set }
    
    func setScreenshot(screenshot: UIImage)
    
    func viewController() -> UIViewController
}
