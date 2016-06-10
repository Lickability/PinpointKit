//
//  BoxAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The default box annotation view.
public class BoxAnnotationView: AnnotationView {

    // MARK: - Properties
    
    /// The corresponding annotation.
    var annotation: BoxAnnotation? {
        didSet {
            layer.shadowPath = annotation.flatMap(PathForDrawingBoxAnnotation)?.CGPath
            setNeedsDisplay()
        }
    }

    override var annotationFrame: CGRect? {
        return annotation?.frame
    }


    // MARK: - Initializers

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        opaque = false
        contentMode = .Redraw

        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UIView

    override public func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }

    override public func drawRect(rect: CGRect) {
        tintColor.setFill()
        annotation?.strokeColor.setStroke()

        let path = annotation.flatMap(PathForDrawingBoxAnnotation)
        path?.fill()
        path?.stroke()
    }

    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return annotation.flatMap(PathForPointInsideBoxAnnotation).map { $0.containsPoint(point) } ?? false
    }


    // MARK: - AnnotationView

    override func setSecondControlPoint(point: CGPoint) {
        guard let previousAnnotation = annotation else { return }

        annotation = BoxAnnotation(startLocation: previousAnnotation.startLocation, endLocation: point, strokeColor: previousAnnotation.strokeColor)
    }

    override func moveControlPoints(translation: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = CGPoint(x: previousAnnotation.startLocation.x + translation.x, y: previousAnnotation.startLocation.y + translation.y)
        let endLocation = CGPoint(x: previousAnnotation.endLocation.x + translation.x, y: previousAnnotation.endLocation.y + translation.y)
        
        annotation = BoxAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
    
    override func scaleControlPoints(scale: CGFloat) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = previousAnnotation.scaledPoint(previousAnnotation.startLocation, scale: scale)
        let endLocation = previousAnnotation.scaledPoint(previousAnnotation.endLocation, scale: scale)
        
        annotation = BoxAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
}

private func PathForDrawingBoxAnnotation(annotation: BoxAnnotation) -> UIBezierPath? {
    let frame = annotation.frame
    let strokeWidth = annotation.strokeWidth
    let borderWidth = annotation.borderWidth
    let cornerRadius = annotation.cornerRadius
    
    let outerBox = frame.insetBy(dx: strokeWidth, dy: strokeWidth)
    let innerBox = outerBox.insetBy(dx: borderWidth + strokeWidth, dy: borderWidth + strokeWidth)
    
    if min(innerBox.size.height, innerBox.size.width) < (borderWidth + strokeWidth) * 2.0 {
        return nil
    }
    
    if min(innerBox.size.height, innerBox.size.width) < cornerRadius * 2.5 {
        return nil
    }
    
    let firstPath = CGPathCreateWithRoundedRect(innerBox, cornerRadius, cornerRadius, nil)
    let secondPath = CGPathCreateCopyByStrokingPath(firstPath, nil, borderWidth + strokeWidth, .Butt, .Bevel, 100)
    
    guard let strokePath = secondPath else { return nil }
    
    let path = UIBezierPath(CGPath: strokePath)
    path.lineWidth = strokeWidth
    path.closePath()
    return path
}

private func PathForPointInsideBoxAnnotation(annotation: BoxAnnotation) -> UIBezierPath? {
    let outsideStrokeWidth = annotation.borderWidth * 2.0
    
    return PathForDrawingBoxAnnotation(annotation)
        .flatMap { path in
            CGPathCreateCopyByStrokingPath(path.CGPath, nil, outsideStrokeWidth, .Butt, .Bevel, 0)
        }
        .map { path in
            UIBezierPath(CGPath: path)
    }
}
