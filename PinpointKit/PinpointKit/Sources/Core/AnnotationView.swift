//
//  AnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The base annotation `UIView` subclass.
open class AnnotationView: UIView {
    
    /// The alpha value used for annotation borders.
    static let BorderAlpha: CGFloat = 0.7
    
    // MARK: - Properties
    
    /// The frame of the annotation view.
    var annotationFrame: CGRect? {
        return nil
    }
    
    // MARK: - Helpers
    
    /**
     Moves the control points of the annotation by the amount specified in `translationAmount`.
     
     - parameter translationAmount: The amount to translate the control points.
     */
    func move(controlPointsBy translationAmount: CGPoint) {
        
    }
    
    /**
     Scales the control points of the annotation by the amount specified in `scaleFactor`.
     
     - parameter scaleFactor: The factor by which to scale the annotation.
     */
    func scale(controlPointsBy scaleFactor: CGFloat) {
        
    }
    
    /**
     Sets the second control point of the annotation to `point`.
     
     - parameter point: The new value for the annotation’s second control point.
     */
    func setSecondControlPoint(_ point: CGPoint) {
        
    }
}
