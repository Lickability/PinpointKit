//
//  EditorDelegate.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A delegate for the Editor.
public protocol EditorDelegate: class {
    
    /**
     A method that is called when the tool selection changes in the editor.
     
     - parameter editor: The editor responsible for editing the image.
     - parameter tool: The tool that was selected.
     
     - note: The default implementation of this method does nothing.
     */
    func editor(_editor: Editor, didSelect tool: Tool)
    
    /**
     A method that is called any time the editor makes a modification to the screenshot.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter change: The change that was made to the screenshot.
     - parameter screenshot: The edited image of a screenshot.
     
     - note: The default implementation of this method does nothing.
     */
    func editor(_ editor: Editor, didMake change: AnnotationChange, to screenshot: UIImage)
    
    /**
     A method that is called with an image to ask if the editor should be dismissed.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     
     - returns: A bool value that defines if the editor dismisses or not. The default implementation of this method returns `true`.
     */
    func editorShouldDismiss(_ editor: Editor, with screenshot: UIImage) -> Bool
    
    /**
     A method that is called with an image just before the editor is dismissed.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     
     - note: The default implementation of this method does nothing.
     */
    func editorWillDismiss(_ editor: Editor, with screenshot: UIImage)
    
    /**
     A method that is called with an image just after the editor was dismissed.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     
     - note: The default implementation of this method does nothing.
     */
    func editorDidDismiss(_ editor: Editor, with screenshot: UIImage)
}

/// Extends editor delegate with base implementation for functions.
extension EditorDelegate {
    
    public func editor(_editor: Editor, didSelect tool: Tool) {
        // Do nothing
    }
    
    public func editor(_ editor: Editor, didMake change: AnnotationChange, to screenshot: UIImage) {
        // Do nothing
    }
    
    public func editorShouldDismiss(_ editor: Editor, with screenshot: UIImage) -> Bool {
        return true
    }
    
    func editorWillDismiss(_ editor: Editor, with screenshot: UIImage) {
        // Do nothing
    }
    
    public func editorDidDismiss(_ editor: Editor, with screenshot: UIImage) {
        // Do nothing
    }
}

/// Represents a change made using the editor.
public enum AnnotationChange {
    
    /// An annotation was added.
    case added
    
    /// An annotation was moved.
    case moved
    
    /// An annotation was brought to front.
    case broughtToFront
    
    /// An annotation was resized.
    case resized
    
    /// A text annotation was edited.
    case textEdited
    
    /// An annotation was deleted. `animated` represents whether the deletion is animated.
    case deleted(animated: Bool)
}
