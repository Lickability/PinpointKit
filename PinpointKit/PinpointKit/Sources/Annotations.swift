//
//  Annotations.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/30/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit
import CoreImage

class Annotation {

    // MARK: - Properties

    let startLocation: CGPoint

    let endLocation: CGPoint
    
    /// The color used to stroke the annotation.
    let strokeColor: UIColor
    
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

    // Point must be on corner of `frame`
    func scaledPoint(point: CGPoint, scale: CGFloat) -> CGPoint {
        var scaledRect = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(scale, scale))
        
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

    init(startLocation: CGPoint = CGPoint.zero, endLocation: CGPoint = CGPoint.zero, strokeColor: UIColor) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.strokeColor = strokeColor
    }
}

class ArrowAnnotation: Annotation {

    // MARK: - Properties

    var arrowLength: CGFloat {
        let horizontalDistance = pow(endLocation.x - startLocation.x, 2.0)
        let verticalDistance = pow(endLocation.y - startLocation.y, 2.0)
        return sqrt(horizontalDistance + verticalDistance)
    }

    var tailWidth: CGFloat {
        return max(4.0, arrowLength * 0.07)
    }

    var headLength: CGFloat {
        return max(10.0, arrowLength / 3.0)
    }

    var headWidth: CGFloat {
        return headLength * 0.9
    }

    var strokeWidth: CGFloat {
        return max(1.0, tailWidth * 0.25)
    }
}

class BoxAnnotation: Annotation {

    // MARK: - Properties

    var borderWidth: CGFloat {
        let size = frame.size
        let maximumWidth = max(4.0, min(size.width, size.height) * 0.075)
        return min(maximumWidth, 14.0)
    }

    var shadowRadius: CGFloat {
        return max(3.0, borderWidth * 0.25)
    }

    var strokeWidth: CGFloat {
        return max(2.0, borderWidth * 0.25)
    }

    var cornerRadius: CGFloat {
        return borderWidth * 2.0
    }
}

class BlurAnnotation: Annotation {

    // MARK: - Properties

    let image: CIImage
    
    var blurredImage: CIImage? {
        var image: CIImage? = self.image
        let extent = image?.extent

        let transform = NSValue(CGAffineTransform: CGAffineTransformIdentity)
        let affineClampFilter = CIFilter(name: "CIAffineClamp")
        affineClampFilter?.setValue(image, forKey: kCIInputImageKey)
        affineClampFilter?.setValue(transform, forKey: kCIInputTransformKey)
        image = affineClampFilter?.valueForKey(kCIOutputImageKey) as? CIImage

        let pixellateFilter = CIFilter(name: "CIPixellate")
        pixellateFilter?.setValue(image, forKey: kCIInputImageKey)
        
        let inputScale = 16
        pixellateFilter?.setValue(inputScale, forKey: kCIInputScaleKey)
        image = pixellateFilter?.valueForKey(kCIOutputImageKey) as? CIImage

        if let imageValue = image, extentValue = extent {
            let vector = CIVector(CGRect: extentValue)
            let filter: CIFilter? = CIFilter(name: "CICrop")
            filter?.setValue(imageValue, forKey: kCIInputImageKey)
            filter?.setValue(vector, forKey: "inputRectangle")
            image = filter?.valueForKey(kCIOutputImageKey) as? CIImage
        }

        return image
    }

    
    // MARK: - Initializers

    init(startLocation: CGPoint, endLocation: CGPoint, image: CIImage) {
        self.image = image
        super.init(startLocation: startLocation, endLocation: endLocation, strokeColor: .clearColor())
    }
}
