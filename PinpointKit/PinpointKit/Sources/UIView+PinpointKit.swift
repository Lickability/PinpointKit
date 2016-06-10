//
//  UIView+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 4/25/16.
//
//

/// Extends UIView to take a snapshot of the screen.
extension UIView {
    
    /// The UIImage representation of this view at the time of access.
    var pinpoint_screenshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
