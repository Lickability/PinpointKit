//
//  Editor.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A protocol describing an object that is responsible for editing a screenshot.
public protocol Editor: AnyObject, InterfaceCustomizable {
    
    /// A delegate for the editor.
    var delegate: EditorDelegate? { get set }
    
    /// The view controller that displays the image being edited.
    var viewController: UIViewController { get }
    
    /// The number of annotations added to the editor.
    var numberOfAnnotations: Int { get }
    
    /// The screenshot, without annotations.
    var screenshot: UIImage? { get set }
    
    /**
     Removes all annotations added to the editor.
     */
    func clearAllAnnotations()
}

extension Editor where Self: UIViewController {
    public var viewController: UIViewController {
        return self
    }
}
