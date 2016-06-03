//
//  Editor.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A protocol describing an object that is responsible for editing a screenshot.
public protocol Editor: class, InterfaceCustomizable {
    
    /// A delegate for the editor.
    weak var delegate: EditorDelegate? { get set }
    
    /// The view controller that displays the image being edited.
    var viewController: UIViewController { get }
    
    /**
     Sets the screenshot to be edited.
     
     - parameter screenshot: The screenshot to be edited.
     */
    func setScreenshot(screenshot: UIImage)
}

extension Editor where Self: UIViewController {
    public var viewController: UIViewController {
        return self
    }
}
