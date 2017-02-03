//
//  Tool.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// Represents an editing tool.
public enum Tool: Int {
    
    /// The arrow tool.
    case arrow
    
    /// The box tool.
    case box
    
    /// The text tool.
    case text
    
    /// The blur tool.
    case blur
    
    /// The name of the tool.
    var name: String {
        switch self {
        case .arrow:
            return "Arrow Tool"
        case .box:
            return "Box Tool"
        case .text:
            return "Text Tool"
        case .blur:
            return "Blur Tool"
        }
    }
    
    /// The image for the tool.
    var image: UIImage {
        let bundle = Bundle.pinpointKitBundle()
        
        func loadImage() -> UIImage? {
            switch self {
            case .arrow:
                return UIImage(named: "ArrowIcon", in: bundle, compatibleWith: nil)
            case .box:
                return UIImage(named: "BoxIcon", in: bundle, compatibleWith: nil)
            case .text:
                return UIImage()
            case .blur:
                return UIImage(named: "BlurIcon", in: bundle, compatibleWith: nil)
            }
        }
        
        return loadImage() ?? UIImage()
    }
    
    /// The item to use for a segmented control.
    var segmentedControlItem: AnyObject {
        switch self {
        case .arrow, .box, .blur:
            let image = self.image
            image.accessibilityLabel = self.name
            return image
        case .text:
            return NSLocalizedString("Aa", comment: "The text tool’s button label.") as AnyObject
        }
    }
}
