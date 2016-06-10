//
//  BezierPath.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/5/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

extension UIBezierPath {
    private static let PaintCodeArrowPathWidth: CGFloat = 267.0
    
    /**
     Creates a bezier path in the shape of an arrow.
     
     - parameter startPoint: The starting control point of the shape.
     - parameter endPoint:   The ending control point of the shape.
     
     - returns: A `UIBezierPath` in the shape of an arrow.
     */
    static func arrowBezierPath(startPoint startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        let length = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)

        // Shape 267x120 from PaintCode. 0 is the mid Y of the arrow to match the original arrow Y.
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 197.29, y: -57.56))
        bezierPath.addLineToPoint(CGPoint(x: 194.32, y: -54.58))
        bezierPath.addCurveToPoint(CGPoint(x: 193.82, y: -43.36), controlPoint1: CGPoint(x: 191.31, y: -51.53), controlPoint2: CGPoint(x: 191.09, y: -46.67))
        bezierPath.addLineToPoint(CGPoint(x: 215.25, y: -17.45))
        bezierPath.addCurveToPoint(CGPoint(x: 213.11, y: -12.74), controlPoint1: CGPoint(x: 216.79, y: -15.59), controlPoint2: CGPoint(x: 215.5, y: -12.77))
        bezierPath.addLineToPoint(CGPoint(x: 8.15, y: -10.22))
        bezierPath.addCurveToPoint(CGPoint(x: 0, y: -1.9), controlPoint1: CGPoint(x: 3.63, y: -10.17), controlPoint2: CGPoint(x: 0, y: -6.46))
        bezierPath.addLineToPoint(CGPoint(x: 0, y: 1.81))
        bezierPath.addCurveToPoint(CGPoint(x: 8.15, y: 10.13), controlPoint1: CGPoint(x: 0, y: 6.37), controlPoint2: CGPoint(x: 3.63, y: 10.08))
        bezierPath.addLineToPoint(CGPoint(x: 213.18, y: 12.65))
        bezierPath.addCurveToPoint(CGPoint(x: 215.33, y: 17.36), controlPoint1: CGPoint(x: 215.58, y: 12.68), controlPoint2: CGPoint(x: 216.86, y: 15.5))
        bezierPath.addLineToPoint(CGPoint(x: 193.82, y: 43.36))
        bezierPath.addCurveToPoint(CGPoint(x: 194.32, y: 54.58), controlPoint1: CGPoint(x: 191.09, y: 46.67), controlPoint2: CGPoint(x: 191.31, y: 51.53))
        bezierPath.addLineToPoint(CGPoint(x: 197.29, y: 57.56))
        bezierPath.addCurveToPoint(CGPoint(x: 208.95, y: 57.56), controlPoint1: CGPoint(x: 200.51, y: 60.81), controlPoint2: CGPoint(x: 205.73, y: 60.81))
        bezierPath.addLineToPoint(CGPoint(x: 266, y: -0))
        bezierPath.addLineToPoint(CGPoint(x: 208.95, y: -57.56))
        bezierPath.addCurveToPoint(CGPoint(x: 197.29, y: -57.56), controlPoint1: CGPoint(x: 205.73, y: -60.81), controlPoint2: CGPoint(x: 200.51, y: -60.81))
        bezierPath.closePath()
        bezierPath.usesEvenOddFillRule = true
        
        bezierPath.applyTransform(transformForStartPoint(startPoint, endPoint: endPoint, length: length))
        
        return bezierPath
    }
    
    private static func transformForStartPoint(startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine = (endPoint.x - startPoint.x) / length
        let sine = (endPoint.y - startPoint.y) / length
        
        let scale: CGFloat = length / PaintCodeArrowPathWidth
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)

        let rotationAndSizeTransform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint.x, ty: startPoint.y)
        return CGAffineTransformConcat(scaleTransform, rotationAndSizeTransform)
    }
}
