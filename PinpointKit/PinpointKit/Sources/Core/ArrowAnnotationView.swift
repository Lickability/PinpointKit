//
//  ArrowAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The default arrow annotation view.
open class ArrowAnnotationView: AnnotationView {

    // MARK: - Properties

    /// The corresponding annotation.
    var annotation: ArrowAnnotation? {
        didSet {
            setNeedsDisplay()
            layer.shadowPath = annotation?.path?.cgPath
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

        isOpaque = false
        contentMode = .redraw

        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    override open func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }

    override open func draw(_ rect: CGRect) {
        tintColor.setFill()
        annotation?.strokeColor.setStroke()

        let path = annotation?.path
        path?.fill()
        path?.stroke()
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return annotation?.touchTargetPath?.contains(point) ?? false
    }

    // MARK: - AnnotationView

    override func setSecondControlPoint(_ point: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        
        annotation = ArrowAnnotation(startLocation: previousAnnotation.startLocation, endLocation: point, strokeColor: previousAnnotation.strokeColor)
    }

    override func move(controlPointsBy translationAmount: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = CGPoint(x: previousAnnotation.startLocation.x + translationAmount.x, y: previousAnnotation.startLocation.y + translationAmount.y)
        let endLocation = CGPoint(x: previousAnnotation.endLocation.x + translationAmount.x, y: previousAnnotation.endLocation.y + translationAmount.y)
        
        annotation = ArrowAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
    
    override func scale(controlPointsBy scaleFactor: CGFloat) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = previousAnnotation.scaledPoint(previousAnnotation.startLocation, scale: scaleFactor)
        let endLocation = previousAnnotation.scaledPoint(previousAnnotation.endLocation, scale: scaleFactor)
        
        annotation = ArrowAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
}

private extension ArrowAnnotation {
    
    var path: UIBezierPath? {
        if arrowLength < headLength * 2.0 {
            return nil
        }
        
        let path = UIBezierPath.arrowBezierPath(startLocation, endPoint: endLocation)
        
        path.lineWidth = strokeWidth
        return path
    }
    
    var touchTargetPath: UIBezierPath? {
        guard let path = path else { return nil }
        
        let outsideStrokeWidth = strokeWidth * 5.0
        
        let strokedPath = path.cgPath.copy(strokingWithWidth: outsideStrokeWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: 0)
        
        return UIBezierPath(cgPath: strokedPath)
    }
}
