//
//  BoxAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/29/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The default box annotation view.
open class BoxAnnotationView: AnnotationView {

    // MARK: - Properties
    
    /// The corresponding annotation.
    var annotation: BoxAnnotation? {
        didSet {
            if let annotation = annotation {
                layer.shadowPath = type(of: self).path(for: annotation)?.cgPath
            } else {
                layer.shadowPath = nil
            }
            
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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    override open func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }

    override open func draw(_ rect: CGRect) {
        guard let annotation = annotation else { return }

        tintColor.setFill()
        annotation.strokeColor.setStroke()

        let path = type(of: self).path(for: annotation)
        path?.fill()
        path?.stroke()
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let annotation = annotation else { return false }
        
        return type(of: self).path(forPointInside: annotation)?.contains(point) ?? false
    }

    // MARK: - AnnotationView

    override func setSecondControlPoint(_ point: CGPoint) {
        guard let previousAnnotation = annotation else { return }

        annotation = BoxAnnotation(startLocation: previousAnnotation.startLocation, endLocation: point, strokeColor: previousAnnotation.strokeColor)
    }

    override func move(controlPointsBy translationAmount: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = CGPoint(x: previousAnnotation.startLocation.x + translationAmount.x, y: previousAnnotation.startLocation.y + translationAmount.y)
        let endLocation = CGPoint(x: previousAnnotation.endLocation.x + translationAmount.x, y: previousAnnotation.endLocation.y + translationAmount.y)
        
        annotation = BoxAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
    
    override func scale(controlPointsBy scaleFactor: CGFloat) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = previousAnnotation.scaledPoint(previousAnnotation.startLocation, scale: scaleFactor)
        let endLocation = previousAnnotation.scaledPoint(previousAnnotation.endLocation, scale: scaleFactor)
        
        annotation = BoxAnnotation(startLocation: startLocation, endLocation: endLocation, strokeColor: previousAnnotation.strokeColor)
    }
}

private extension BoxAnnotationView {
    
    static func path(for annotation: BoxAnnotation) -> UIBezierPath? {
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
        let secondPath = firstPath.copy(strokingWithWidth: borderWidth + strokeWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: 100)
        
        let path = UIBezierPath(cgPath: secondPath)
        path.lineWidth = strokeWidth
        path.close()
        return path
    }
    
    static func path(forPointInside annotation: BoxAnnotation) -> UIBezierPath? {
        let outsideStrokeWidth = annotation.borderWidth * 2.0
        
        return path(for: annotation)
            .flatMap { path in
                path.cgPath.copy(strokingWithWidth: outsideStrokeWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: 0)
            }
            .map { path in
                UIBezierPath(cgPath: path)
        }
    }
}
