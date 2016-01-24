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

    static func arrowBezierPath(startPoint startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        let length = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)

        // Shape 267x120 from PaintCode. 0 is the mid Y of the arrow to match the original arrow Y.
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(197.29, -57.56))
        bezierPath.addLineToPoint(CGPointMake(194.32, -54.58))
        bezierPath.addCurveToPoint(CGPointMake(193.82, -43.36), controlPoint1: CGPointMake(191.31, -51.53), controlPoint2: CGPointMake(191.09, -46.67))
        bezierPath.addLineToPoint(CGPointMake(215.25, -17.45))
        bezierPath.addCurveToPoint(CGPointMake(213.11, -12.74), controlPoint1: CGPointMake(216.79, -15.59), controlPoint2: CGPointMake(215.5, -12.77))
        bezierPath.addLineToPoint(CGPointMake(8.15, -10.22))
        bezierPath.addCurveToPoint(CGPointMake(0, -1.9), controlPoint1: CGPointMake(3.63, -10.17), controlPoint2: CGPointMake(0, -6.46))
        bezierPath.addLineToPoint(CGPointMake(0, 1.81))
        bezierPath.addCurveToPoint(CGPointMake(8.15, 10.13), controlPoint1: CGPointMake(0, 6.37), controlPoint2: CGPointMake(3.63, 10.08))
        bezierPath.addLineToPoint(CGPointMake(213.18, 12.65))
        bezierPath.addCurveToPoint(CGPointMake(215.33, 17.36), controlPoint1: CGPointMake(215.58, 12.68), controlPoint2: CGPointMake(216.86, 15.5))
        bezierPath.addLineToPoint(CGPointMake(193.82, 43.36))
        bezierPath.addCurveToPoint(CGPointMake(194.32, 54.58), controlPoint1: CGPointMake(191.09, 46.67), controlPoint2: CGPointMake(191.31, 51.53))
        bezierPath.addLineToPoint(CGPointMake(197.29, 57.56))
        bezierPath.addCurveToPoint(CGPointMake(208.95, 57.56), controlPoint1: CGPointMake(200.51, 60.81), controlPoint2: CGPointMake(205.73, 60.81))
        bezierPath.addLineToPoint(CGPointMake(266, -0))
        bezierPath.addLineToPoint(CGPointMake(208.95, -57.56))
        bezierPath.addCurveToPoint(CGPointMake(197.29, -57.56), controlPoint1: CGPointMake(205.73, -60.81), controlPoint2: CGPointMake(200.51, -60.81))
        bezierPath.closePath()
        bezierPath.usesEvenOddFillRule = true;
        
        bezierPath.applyTransform(transformForStartPoint(startPoint, endPoint: endPoint, length: length))
        
        return bezierPath
    }
    
    static func transformForStartPoint(startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine = (endPoint.x - startPoint.x) / length
        let sine = (endPoint.y - startPoint.y) / length
        
        let scale: CGFloat = length / PaintCodeArrowPathWidth
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)

        let rotationAndSizeTransform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint.x, ty: startPoint.y)
        return CGAffineTransformConcat(scaleTransform, rotationAndSizeTransform)
    }
}

