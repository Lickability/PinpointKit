//
//  Screen.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/6/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// Extends `UIScreen` to add convenience properties.
extension UIScreen {
    
    /// The height of a single pixel on the screen, in points.
    var pixelHeight: CGFloat {
        return 1.0 / scale
    }
    
    /// The size of the receiver when in portrait orientation.
    var portraitPixelSize: CGSize {
        let coordinateSpaceBounds = fixedCoordinateSpace.bounds
        
        return CGSize(width: coordinateSpaceBounds.width * scale, height: coordinateSpaceBounds.height * scale)
    }
}
