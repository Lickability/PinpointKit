//
//  ArrowAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

extension ArrowAnnotation {
    var path: UIBezierPath? {
        if arrowLength < headLength * 2.0 {
            return nil
        }
        
        let path = UIBezierPath.arrowBezierPath(
            startPoint: startLocation,
            endPoint: endLocation
        )
        
        path.lineWidth = strokeWidth
        return path
    }
    
    var touchTargetPath: UIBezierPath? {
        let outsideStrokeWidth = strokeWidth * 5.0
        
        return path
            .flatMap { CGPathCreateCopyByStrokingPath($0.CGPath, nil, outsideStrokeWidth, .Butt, .Bevel, 0) }
            .map { UIBezierPath(CGPath: $0) }
    }
}

class ArrowAnnotationView: AnnotationView {

    // MARK: - Properties

    var annotation: ArrowAnnotation? {
        didSet {
            setNeedsDisplay()
            layer.shadowPath = annotation?.path?.CGPath
        }
    }

    override var annotationFrame: CGRect? {
        return annotation?.path?.bounds
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
        annotation?.strokeColor.setStroke()

        let path = annotation?.path
        path?.fill()
        path?.stroke()
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let path = annotation?.touchTargetPath
        return path.map { $0.containsPoint(point) } ?? false
    }


    // MARK: - AnnotationView

    override func setSecondControlPoint(point: CGPoint) {
        annotation = annotation.map {
            ArrowAnnotation(startLocation: $0.startLocation, endLocation: point, strokeColor: $0.strokeColor)
        }
    }

    override func moveControlPoints(translation: CGPoint) {
        annotation = annotation.map {
            let startLocation = CGPoint(x: $0.startLocation.x + translation.x, y: $0.startLocation.y + translation.y)
            let endLocation = CGPoint(x: $0.endLocation.x + translation.x, y: $0.endLocation.y + translation.y)
            return ArrowAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: $0.strokeColor)
        }
    }
    
    override func scaleControlPoints(scale: CGFloat) {
        annotation = annotation.map {
            let startLocation = $0.scaledPoint($0.startLocation, scale: scale)
            let endLocation = $0.scaledPoint($0.endLocation, scale: scale)
            return ArrowAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: $0.strokeColor)
        }
    }
}
