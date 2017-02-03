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
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            preconditionFailure("`UIGraphicsGetImageFromCurrentImageContext()` should never return `nil` as we satisify the requirements of having a bitmap-based current context created with `UIGraphicsBeginImageContextWithOptions(_:_:_:)`")
        }
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
