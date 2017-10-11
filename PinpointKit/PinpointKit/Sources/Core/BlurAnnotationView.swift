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
open class BlurAnnotationView: AnnotationView, GLKViewDelegate {

    // MARK: - Properties

    private let EAGLContext: OpenGLES.EAGLContext?
    private let GLKView: GLKit.GLKView?
    private let CIContext: CoreImage.CIContext?

    /// The corresponding annotation.
    var annotation: BlurAnnotation? {
        didSet {
            setNeedsDisplay()
            
            let layer = CAShapeLayer()
            if let annotationFrame = annotationFrame {
                layer.path = UIBezierPath(rect: annotationFrame).cgPath
            }
            
            GLKView?.layer.mask = layer
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
        
        if let EAGLContext = OpenGLES.EAGLContext(api: .openGLES2) {
            self.EAGLContext = EAGLContext
            GLKView = GLKit.GLKView(frame: bounds, context: EAGLContext)
            CIContext = CoreImage.CIContext(eaglContext: EAGLContext, options: [
                kCIContextUseSoftwareRenderer: false
            ])
        } else {
            EAGLContext = nil
            GLKView = nil
            CIContext = nil
        }

        super.init(frame: frame)

        isOpaque = false
        
        GLKView?.isUserInteractionEnabled = false
        GLKView?.delegate = self
        GLKView?.contentMode = .redraw
        
        if let glkView = GLKView {
            addSubview(glkView)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView

    override open func layoutSubviews() {
        super.layoutSubviews()
        GLKView?.frame = bounds
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return touchTargetFrame?.contains(point) ?? false
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if drawsBorder {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            tintColor?.withAlphaComponent(type(of: self).BorderAlpha).setStroke()
            
            // Since this draws under the GLKView, and strokes extend both inside and outside, we have to double the intended width.
            let strokeWidth: CGFloat = 1.0
            context.setLineWidth(strokeWidth * 2.0)
            
            let rect = annotationFrame ?? CGRect.zero
            context.stroke(rect)
        }
    }
        
    // MARK: - AnnotationView

    override func setSecondControlPoint(_ point: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        
        annotation = BlurAnnotation(startLocation: previousAnnotation.startLocation, endLocation: point, image: previousAnnotation.image)
    }

    override func move(controlPointsBy translationAmount: CGPoint) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = CGPoint(x: previousAnnotation.startLocation.x + translationAmount.x, y: previousAnnotation.startLocation.y + translationAmount.y)
        let endLocation = CGPoint(x: previousAnnotation.endLocation.x + translationAmount.x, y: previousAnnotation.endLocation.y + translationAmount.y)
        
        annotation = BlurAnnotation(startLocation: startLocation, endLocation: endLocation, image: previousAnnotation.image)
    }

    override func scale(controlPointsBy scaleFactor: CGFloat) {
        guard let previousAnnotation = annotation else { return }
        let startLocation = previousAnnotation.scaledPoint(previousAnnotation.startLocation, scale: scaleFactor)
        let endLocation = previousAnnotation.scaledPoint(previousAnnotation.endLocation, scale: scaleFactor)
        
        annotation = BlurAnnotation(startLocation: startLocation, endLocation: endLocation, image: previousAnnotation.image)
    }

    // MARK: - GLKViewDelegate

    open func glkView(_ view: GLKit.GLKView, drawIn rect: CGRect) {
        
        glClearColor(0, 0, 0, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        guard let CIContext = self.CIContext else { return }
        guard let image = annotation?.blurredImage else { return }

        let drawableRect = CGRect(x: 0, y: 0, width: view.drawableWidth, height: view.drawableHeight)
        CIContext.draw(image, in: drawableRect, from: image.extent)
        
    }
}
