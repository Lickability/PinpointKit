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
     A function that is called with an image just before the editor is dismissed.
     
     - parameter editor: The editor resonsible for editing the image.
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     */
    func editorWillDismiss(editor: Editor, screenshot: UIImage)
    
    /**
     A function that is called with an image to ask if the editor should be dismissed.
 
    - parameter editor: The editor resonsible for editing the image.
    - parameter screenshot: The edited image of a screenshot, after editing is complete.
    
    - returns: A bool value that defines if the editor dismisses or not.
     */
    func editorShouldDismiss(editor: Editor, screenshot: UIImage) -> Bool
}

/// Extends editor delegate with base implementation for functions.
extension EditorDelegate {
    public func editorShouldDismiss(editor: Editor, screenshot: UIImage) -> Bool {
        return true
    }
}
