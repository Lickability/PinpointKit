//
//  Screen.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/6/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

extension UIScreen {
    func pixelSize() -> CGSize {
        let screenPointSize = UIScreen.mainScreen().bounds.size
        let scale = UIScreen.mainScreen().scale

        return CGSize(width: screenPointSize.width * scale, height: screenPointSize.height * scale)
    }
    
    func portraitPixelSize() -> CGSize {
        let coordinateSpaceBounds = UIScreen.mainScreen().fixedCoordinateSpace.bounds
        let scale = UIScreen.mainScreen().scale
        
        return CGSize(width: coordinateSpaceBounds.width * scale, height: coordinateSpaceBounds.height * scale)
    }
}
