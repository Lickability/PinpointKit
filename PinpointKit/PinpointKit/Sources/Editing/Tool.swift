//
//  Tool.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// Represents an editing tool.
enum Tool: Int {
    
    /// The arrow tool.
    case Arrow
    
    /// The box tool.
    case Box
    
    /// The text tool.
    case Text
    
    /// The blur tool.
    case Blur
    
    /// The name of the tool.
    var name: String {
        switch self {
        case .Arrow:
            return "Arrow Tool"
        case .Box:
            return "Box Tool"
        case .Text:
            return "Text Tool"
        case .Blur:
            return "Blur Tool"
        }
    }
    
    /// The image for the tool.
    var image: UIImage {
        let bundle = NSBundle.pinpointKitBundle()
        
        func loadImage() -> UIImage? {
            switch self {
            case .Arrow:
                return UIImage(named: "ArrowIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
            case .Box:
                return UIImage(named: "BoxIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
            case .Text:
                return UIImage()
            case .Blur:
                return UIImage(named: "BlurIcon", inBundle: bundle, compatibleWithTraitCollection: nil)
            }
        }
        
        return loadImage() ?? UIImage()
    }
    
    /// The item to use for a segmented control.
    var segmentedControlItem: AnyObject {
        switch self {
        case .Arrow, .Box, .Blur:
            let image = self.image
            image.accessibilityLabel = self.name
            return image
        case .Text:
            return NSLocalizedString("Aa", comment: "The text tool’s button label.")
        }
    }
}
