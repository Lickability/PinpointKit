//
//  BoxAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

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

class BoxAnnotationView: AnnotationView {

    // MARK: - Properties

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UIView

    override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        tintColor.setFill()
        UIColor.whiteColor().setStroke()

        let path = annotation.flatMap(PathForDrawingBoxAnnotation)
        path?.fill()
        path?.stroke()
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return annotation.flatMap(PathForPointInsideBoxAnnotation).map({ $0.containsPoint(point) }) ?? false
    }


    // MARK: - AnnotationView

    override func setSecondControlPoint(point: CGPoint) {
        annotation = annotation.map({
            BoxAnnotation(startLocation: $0.startLocation, endLocation: point)
        })
    }

    override func moveControlPoints(translation: CGPoint) {
        annotation = annotation.map({
            let startLocation = CGPoint(x: $0.startLocation.x + translation.x, y: $0.startLocation.y + translation.y)
            let endLocation = CGPoint(x: $0.endLocation.x + translation.x, y: $0.endLocation.y + translation.y)
            return BoxAnnotation(startLocation: startLocation, endLocation: endLocation)
        })
    }
    
    override func scaleControlPoints(scale: CGFloat) {
        annotation = annotation.map({
            let startLocation = $0.scaledPoint($0.startLocation, scale: scale)
            let endLocation = $0.scaledPoint($0.endLocation, scale: scale)
            return BoxAnnotation(startLocation: startLocation, endLocation: endLocation)
        })
    }
}
