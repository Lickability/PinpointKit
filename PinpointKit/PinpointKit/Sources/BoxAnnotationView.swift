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
            layer.shadowPath = annotation.flatMap(PathForDrawingBoxAnnotation)?.cgPath
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

        isOpaque = false
        contentMode = .redraw

        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.black().cgColor
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

    override public func draw(_ rect: CGRect) {
        tintColor.setFill()
        annotation?.strokeColor.setStroke()

        let path = annotation.flatMap(PathForDrawingBoxAnnotation)
        path?.fill()
        path?.stroke()
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return annotation.flatMap(PathForPointInsideBoxAnnotation).map { $0.contains(point) } ?? false
    }


    // MARK: - AnnotationView

    override func setSecondControlPoint(_ point: CGPoint) {
        guard let previousAnnotation = annotation else { return }

        annotation = BoxAnnotation(startLocation: previousAnnotation.startLocation, endLocation: point, strokeColor: previousAnnotation.strokeColor)
    }

    override func moveControlPoints(_ translation: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = CGPoint(x: previousAnnotation.startLocation.x + translation.x, y: previousAnnotation.startLocation.y + translation.y)
        let endLocation = CGPoint(x: previousAnnotation.endLocation.x + translation.x, y: previousAnnotation.endLocation.y + translation.y)
        
        annotation = BoxAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
    
    override func scaleControlPoints(_ scale: CGFloat) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = previousAnnotation.scaledPoint(previousAnnotation.startLocation, scale: scale)
        let endLocation = previousAnnotation.scaledPoint(previousAnnotation.endLocation, scale: scale)
        
        annotation = BoxAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
}

private func PathForDrawingBoxAnnotation(_ annotation: BoxAnnotation) -> UIBezierPath? {
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
    
    let firstPath = CGPath(roundedRect: innerBox, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    let secondPath = CGPath(copyByStroking: firstPath, transform: nil, lineWidth: borderWidth + strokeWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: 100)
    
    guard let strokePath = secondPath else { return nil }
    
    let path = UIBezierPath(cgPath: strokePath)
    path.lineWidth = strokeWidth
    path.close()
    return path
}

private func PathForPointInsideBoxAnnotation(_ annotation: BoxAnnotation) -> UIBezierPath? {
    let outsideStrokeWidth = annotation.borderWidth * 2.0
    
    return PathForDrawingBoxAnnotation(annotation)
        .flatMap { path in
            CGPath(copyByStroking: path.cgPath, transform: nil, lineWidth: outsideStrokeWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: 0)
        }
        .map { path in
            UIBezierPath(cgPath: path)
    }
}
