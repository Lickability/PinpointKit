//
//  EditImageViewControllerDelegate.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 5/9/16.
//
//

/// A delegate for the EditImageViewController.
public protocol EditImageViewControllerDelegate: class {
    
    /**
     A method that is called with an image after a screenshot is edited.
     
     - parameter screenshot: The edited image of a screenshot, after editing is complete.
     */
    func didTapCloseButton(screenshot: UIImage)
}
