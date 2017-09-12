//
//  Annotations.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/30/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit
import CoreImage

/// Base type for representing annotations that can be added to images.
class Annotation {

    // MARK: - Properties
    
    /// The start location of the annotation.
    let startLocation: CGPoint

    /// The end location of the annotation.
    let endLocation: CGPoint
    
    /// The color used to stroke the annotation.
    let strokeColor: UIColor
    
    /// The frame of the annotation.
    var frame: CGRect {
        let origin = CGPoint(
            x: min(startLocation.x, endLocation.x),
            y: min(startLocation.y, endLocation.y)
        )
        let size = CGSize(
            width: max(startLocation.x, endLocation.x) - origin.x,
            height: max(startLocation.y, endLocation.y) - origin.y
        )
        return CGRect(origin: origin, size: size)
    }

    /**
     Creates a new `CGPoint` from an existing point if `frame` were scaled by the specified amount.
     
     - parameter point: The existing point to scale.
     - parameter scale: The amount to scale.
     
     - note: `point` must be on a corner of `frame`.
     
     - returns: The scaled point.
     */
    func scaledPoint(_ point: CGPoint, scale: CGFloat) -> CGPoint {
        var scaledRect = frame.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        let centeredXDistance = scaledRect.width / 2.0 - frame.width / 2.0
        let centeredYDistance = scaledRect.height / 2.0 - frame.height / 2.0

        scaledRect.origin = CGPoint(x: frame.minX - centeredXDistance, y: frame.minY - centeredYDistance)
        
        var newPoint: CGPoint = CGPoint.zero
        if point.x == frame.minX {
            newPoint.x = scaledRect.minX
        } else if point.x == frame.maxX {
            newPoint.x = scaledRect.maxX
        }
        
        if point.y == frame.minY {
            newPoint.y = scaledRect.minY
        } else if point.y == frame.maxY {
            newPoint.y = scaledRect.maxY
        }
        
        return newPoint
    }

    // MARK: - Initializers

    /**
     Creates a new annotation.
     
     - parameter startLocation: The start location of the annotation.
     - parameter endLocation:   The end location of the annotation.
     - parameter strokeColor:   The color used to stroke the annotation.
     */
    init(startLocation: CGPoint = CGPoint.zero, endLocation: CGPoint = CGPoint.zero, strokeColor: UIColor) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.strokeColor = strokeColor
    }
}

/// An `Annotation` that represents an arrow.
class ArrowAnnotation: Annotation {

    // MARK: - Properties

    /// The length of the arrow annotation.
    var arrowLength: CGFloat {
        let horizontalDistance = pow(endLocation.x - startLocation.x, 2.0)
        let verticalDistance = pow(endLocation.y - startLocation.y, 2.0)
        return sqrt(horizontalDistance + verticalDistance)
    }

    /// The width of the tail of the arrow.
    var tailWidth: CGFloat {
        return max(4.0, arrowLength * 0.07)
    }

    /// The length of the head of the arrow.
    var headLength: CGFloat {
        return max(10.0, arrowLength / 3.0)
    }
    
    /// The width of the head of the arrow.
    var headWidth: CGFloat {
        return headLength * 0.9
    }
    
    /// The width of the stroke of the arrow.
    var strokeWidth: CGFloat {
        return max(1.0, tailWidth * 0.25)
    }
}

/// An annotation that represents a box.
class BoxAnnotation: Annotation {

    // MARK: - Properties

    /// The border width of the box.
    var borderWidth: CGFloat {
        let size = frame.size
        let maximumWidth = max(4.0, min(size.width, size.height) * 0.075)
        return min(maximumWidth, 14.0)
    }

    /// The shadow radius of the box.
    var shadowRadius: CGFloat {
        return max(3.0, borderWidth * 0.25)
    }

    /// The stroke width of the box.
    var strokeWidth: CGFloat {
        return max(2.0, borderWidth * 0.25)
    }
    
    /// The corner radius of the box.
    var cornerRadius: CGFloat {
        return borderWidth * 2.0
    }
}

/// An annotation that represents a blur.
class BlurAnnotation: Annotation {

    // MARK: - Properties
    
    /// The `CGImage`-representation of the image to blur.
    let image: CIImage
    
    /// The blurred representation of the image.
    var blurredImage: CIImage? {
        var image: CIImage? = self.image
        let extent = image?.extent

        let transform = NSValue(cgAffineTransform: CGAffineTransform.identity)
        let affineClampFilter = CIFilter(name: "CIAffineClamp")
        affineClampFilter?.setValue(image, forKey: kCIInputImageKey)
        affineClampFilter?.setValue(transform, forKey: kCIInputTransformKey)
        image = affineClampFilter?.value(forKey: kCIOutputImageKey) as? CIImage

        let pixellateFilter = CIFilter(name: "CIPixellate")
        pixellateFilter?.setValue(image, forKey: kCIInputImageKey)
        
        let inputScale = 16
        pixellateFilter?.setValue(inputScale, forKey: kCIInputScaleKey)
        image = pixellateFilter?.value(forKey: kCIOutputImageKey) as? CIImage
        
        if let imageValue = image {
            if let extentValue = extent {
                let vector = CIVector(cgRect: extentValue)
                let filter: CIFilter? = CIFilter(name: "CICrop")
                filter?.setValue(imageValue, forKey: kCIInputImageKey)
                filter?.setValue(vector, forKey: "inputRectangle")
                image = filter?.value(forKey: kCIOutputImageKey) as? CIImage
            }
        }

        return image
    }
    
    // MARK: - Initializers

    /**
     Creates a new blur annotation.
     
     - parameter startLocation: The start location of the annotation.
     - parameter endLocation:   The end location of the annotation.
     - parameter image:         The `CGIImage`-representation of the image to blur.
     */
    init(startLocation: CGPoint, endLocation: CGPoint, image: CIImage) {
        self.image = image
        super.init(startLocation: startLocation, endLocation: endLocation, strokeColor: .clear)
    }
}
