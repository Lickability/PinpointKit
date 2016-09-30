//
//  Screen.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/6/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// Extends `UIScreen` to identify the pixel size for a screen.
extension UIScreen {
    
    /**
     Identifies the size of the pixel when the screen is in portrait.
     
     - returns: The size of a pixel for the screen's portrait dimensions.
     */
    func portraitPixelSize() -> CGSize {
        let coordinateSpaceBounds = fixedCoordinateSpace.bounds
        
        return CGSize(width: coordinateSpaceBounds.width * scale, height: coordinateSpaceBounds.height * scale)
    }
}
