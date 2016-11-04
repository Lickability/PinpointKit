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
     A method that is called with an image just before the editor is dismissed.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     */
    func editorWillDismiss(_ editor: Editor, with screenshot: UIImage)
    
    /**
     A method that is called with an image just after the editor was dismissed.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     */
    func editorDidDismiss(_ editor: Editor, with screenshot: UIImage)
    
    /**
     A method that is called with an image to ask if the editor should be dismissed.
 
    - parameter editor: The editor resonsible for editing the image.
    - parameter screenshot: The edited image of a screenshot, after editing is complete.
    
    - returns: A bool value that defines if the editor dismisses or not.
     */
    func editorShouldDismiss(_ editor: Editor, with screenshot: UIImage) -> Bool
    
    /**
     A method that is called any time the editor makes a modification to the screenshot.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot.
     */
    func editorDidMakeChanges(_ editor: Editor, to screenshot: UIImage)
}

/// Extends editor delegate with base implementation for functions.
extension EditorDelegate {
    
    public func editorDidDismiss(_ editor: Editor, with screenshot: UIImage) {
        // Do nothing
    }
    
    public func editorShouldDismiss(_ editor: Editor, with screenshot: UIImage) -> Bool {
        return true
    }
    
    public func editorDidMakeChanges(_ editor: Editor, to screenshot: UIImage) {
        // Do nothing
    }
}