//
//  EditImageViewControllerBarButtonItemProviding.swift
//  Pods
//
//  Created by Michael Liberatore on 11/4/16.
//
//

import UIKit

/// Describes a type that specifies the bar button items of an `EditImageViewController` and their behaviors.
public protocol EditImageViewControllerBarButtonItemProviding {
    
    /// The left bar button item.
    var leftBarButtonItem: UIBarButtonItem? { get }
    
    /// The right bar button item.
    var rightBarButtonItem: UIBarButtonItem? { get }
    
    /// Whether the `EditImageViewController` hides the bar button items while editing a text annotation to display its own dismiss button for ending the editing of text.
    var hidesBarButtonItemsWhileEditingTextAnnotations: Bool { get }
}
