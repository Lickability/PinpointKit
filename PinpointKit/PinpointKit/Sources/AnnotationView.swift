//
//  AnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The alpha value used for annotation borders.
let BorderAlpha: CGFloat = 0.7

/// The base annotation `UIView` subclass.
public protocol AnnotationView {
    
    // MARK: - Properties
    
    /// The frame of the annotation view.
    var annotationFrame: CGRect? { get }
    
    // MARK: - Helpers
    
    /**
     Moves the control points of the annotation by the amount specified in `translation`.
     
     - parameter translation: The amount to translate the control points.
     */
    func moveControlPoints(translation: CGPoint)
    
    /**
     Scales the control points of the annotation by the amount specified in `scale`.
     
     - parameter scale: The factor by which to scale the annotation.
     */
    func scaleControlPoints(scale: CGFloat)
    
    /**
     Sets the second control point of the annotation to `point`.
     
     - parameter point: The new value for the annotation’s second control point.
     */
    func setSecondControlPoint(point: CGPoint)
    
    func view() -> UIView
}

extension AnnotationView where Self: UIView {
    public func view() -> UIView {
        return self
    }
}
