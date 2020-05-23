//
//  UIView+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 4/25/16.
//
//

/// Extends `UIView` to take a snapshot of the screen.
extension UIView {
    
    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.
    func snapshot(of rect: CGRect? = nil) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect ?? bounds)
        let image = renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}
