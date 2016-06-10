//
//  AnnotationViewFactory.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A factory that constructs `AnnotationView`s.
struct AnnotationViewFactory {
    
    /// The image to annotate.
    let image: QuartzCore.CGImage?
    
    /// The current location to start the annotation.
    let currentLocation: CGPoint
    
    /// The tool to annotate with.
    let tool: Tool
    
    /// The stroke color of the annotation.
    let strokeColor: UIColor
    
    /**
     Constructs an annotation view.
     
     - returns: An annotation view built from the specified parameters upon initialization.
     */
    func annotationView() -> AnnotationView {
        switch tool {
        case .Arrow:
            let view = ArrowAnnotationView()
            view.annotation = ArrowAnnotation(startLocation: currentLocation, endLocation: currentLocation, strokeColor: strokeColor)
            return view
        case .Box:
            let view = BoxAnnotationView()
            view.annotation = BoxAnnotation(startLocation: currentLocation, endLocation: currentLocation, strokeColor: strokeColor)
            return view
        case .Text:
            let view = TextAnnotationView()
            let minimumSize = view.minimumTextSize
            let endLocation = CGPoint(x: currentLocation.x + minimumSize.width, y: currentLocation.y + minimumSize.height)
            view.annotation = Annotation(startLocation: currentLocation, endLocation: endLocation, strokeColor: strokeColor)
            return view
        case .Blur:
            let view = BlurAnnotationView()
            view.drawsBorder = true
            
            if let image = image {
                let CIImage = CoreImage.CIImage(CGImage: image)
                view.annotation = BlurAnnotation(startLocation: currentLocation, endLocation: currentLocation, image: CIImage)
            }
            
            return view
        }
    }
}
