//
//  BlurAnnotationView.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/30/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit
import GLKit
import CoreImage

/// The default blur annotation view.
public class BlurAnnotationView: AnnotationView, GLKViewDelegate {

    // MARK: - Properties

    private let EAGLContext: OpenGLES.EAGLContext
    private let GLKView: GLKit.GLKView
    private let CIContext: CoreImage.CIContext

    /// The corresponding annotation.
    var annotation: BlurAnnotation? {
        didSet {
            setNeedsDisplay()
            
            let layer = CAShapeLayer()
            if let annotationFrame = annotationFrame {
                layer.path = UIBezierPath(rect: annotationFrame).CGPath
            }
            
            GLKView.layer.mask = layer
        }
    }
    
    /// Whether to draw a border on the blur view.
    var drawsBorder = false {
        didSet {
            if drawsBorder != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    override var annotationFrame: CGRect? {
        return annotation?.frame
    }
    
    private var touchTargetFrame: CGRect? {
        guard let annotationFrame = annotationFrame else { return nil }
        
        let size = frame.size
        let maximumWidth = max(4.0, min(size.width, size.height) * 0.075)
        let outsideStrokeWidth = min(maximumWidth, 14.0) * 1.5
        
        return UIEdgeInsetsInsetRect(annotationFrame, UIEdgeInsets(top: -outsideStrokeWidth, left: -outsideStrokeWidth, bottom: -outsideStrokeWidth, right: -outsideStrokeWidth))
    }
    
    // MARK: - Initializers
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    public override init(frame: CGRect) {
        let bounds = CGRect(origin: CGPoint.zero, size: frame.size)

        EAGLContext = OpenGLES.EAGLContext(API: .OpenGLES2)
        GLKView = GLKit.GLKView(frame: bounds, context: EAGLContext)
        CIContext = CoreImage.CIContext(EAGLContext: EAGLContext, options: [
            kCIContextUseSoftwareRenderer: false
        ])

        super.init(frame: frame)

        opaque = false
        
        GLKView.userInteractionEnabled = false
        GLKView.delegate = self
        GLKView.contentMode = .Redraw
        addSubview(GLKView)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UIView

    override public func layoutSubviews() {
        super.layoutSubviews()
        GLKView.frame = bounds
    }

    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return touchTargetFrame?.contains(point) ?? false
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if drawsBorder {
            let context = UIGraphicsGetCurrentContext()
            tintColor?.colorWithAlphaComponent(self.dynamicType.BorderAlpha).setStroke()
            
            // Since this draws under the GLKView, and strokes extend both inside and outside, we have to double the intended width.
            let strokeWidth: CGFloat = 1.0
            CGContextSetLineWidth(context, strokeWidth * 2.0)
            
            let rect = annotationFrame ?? CGRect.zero
            CGContextStrokeRect(context, rect)
        }
    }
        
    // MARK: - AnnotationView

    override func setSecondControlPoint(point: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        
        annotation = BlurAnnotation(startLocation: previousAnnotation.startLocation, endLocation: point, image: previousAnnotation.image)
    }

    override func moveControlPoints(translation: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = CGPoint(x: previousAnnotation.startLocation.x + translation.x, y: previousAnnotation.startLocation.y + translation.y)
        let endLocation = CGPoint(x: previousAnnotation.endLocation.x + translation.x, y: previousAnnotation.endLocation.y + translation.y)
        
        annotation = BlurAnnotation(startLocation: startLocation, endLocation: endLocation, image: previousAnnotation.image)
    }

    override func scaleControlPoints(scale: CGFloat) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = previousAnnotation.scaledPoint(previousAnnotation.startLocation, scale: scale)
        let endLocation = previousAnnotation.scaledPoint(previousAnnotation.endLocation, scale: scale)
        
        annotation = BlurAnnotation(startLocation: startLocation, endLocation: endLocation, image: previousAnnotation.image)
    }

    // MARK: - GLKViewDelegate

    public func glkView(view: GLKit.GLKView, drawInRect rect: CGRect) {
        glClearColor(0, 0, 0, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        if let image = annotation?.blurredImage {
            let drawableRect = CGRect(x: 0, y: 0, width: view.drawableWidth, height: view.drawableHeight)
            CIContext.drawImage(image, inRect: drawableRect, fromRect: image.extent)
        }
    }
}
