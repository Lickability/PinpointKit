//
//  Fonts.swift
//  Pinpoint
//
//  Created by Matthew Bischoff on 4/18/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit


/// Describes the weight of a font.
public enum FontWeight: Int {
    
    /// Regular weight.
    case Regular
    
    /// Semibold weight.
    case Semibold
    
    /// Bold weight.
    case Bold
}

public extension UIFont {
    
    /**
     Creates a Source Sans Pro font at the specified size and weight.
     
     - parameter fontSize: The size of the font.
     - parameter weight:   The weight of the font.
     
     - returns: A Source Sans Pro `UIFont` at the specified size and weight.
     */
    public static func sourceSansProFontOfSize(fontSize: CGFloat, weight: FontWeight = .Regular) -> UIFont {
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
     Creates a Menlo font at regular weight and the specified size.
     
     - parameter fontSize: The size font.
     
     - returns: A `UIFont` representing Menlo Regular at the specified size.
     */
    public static func menloRegularFontOfSize(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Menlo-Regular", size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
    }
}
