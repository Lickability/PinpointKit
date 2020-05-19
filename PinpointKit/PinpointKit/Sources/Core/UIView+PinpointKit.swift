//
//  UIView+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 4/25/16.
//
//

/// Extends `UIView` to take a snapshot of the screen.
extension UIView {
    
     /// The `UIImage` representation of a view cropped to the provided frame
    func imageSnapshotCroppedToFrame(_ frame: CGRect?) -> UIImage {
        let scaleFactor = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scaleFactor)
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        var image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        if let frame = frame {
            // UIImages are measured in points, but CGImages are measured in pixels
            let scaledRect = frame.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))

            if let cgImage = image.cgImage, let imageRef = cgImage.cropping(to: scaledRect) {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
}
