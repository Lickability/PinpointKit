//
//  Fonts.swift
//  Pinpoint
//
//  Created by Matthew Bischoff on 4/18/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/**
 Describes the weight of a font.
 
 - Regular:  Regular weight.
 - Semibold: Semibold weight.
 - Bold:     Bold weight.
 */
public enum FontWeight: Int {
    case Regular
    case Semibold
    case Bold
}

public extension UIFont {
    
    public static func sourceSansProFontOfSize(fontSize: CGFloat, weight: FontWeight) -> UIFont {
        let fontName: String = {
            switch weight {
            case .Regular:
                return "SourceSansPro-Regular"
            case .Semibold:
                return "SourceSansPro-Semibold"
            case .Bold:
                return "SourceSansPro-Bold"
            }
        }()
        
        if let fontURL = NSBundle.pinpointKitBundle().URLForResource(fontName, withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL, .Process, nil)
        }
        
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
    
    /**
     Returns the Menlo font at regular weight and the given size.
     
     - parameter fontSize: The size font to be returned
     
     - returns: A `UIFont` object representing Menlo Regular at the provided size.
     */
    public static func menloRegularFontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Menlo-Regular", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
}
