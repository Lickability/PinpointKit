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
    case regular
    
    /// Semibold weight.
    case semibold
    
    /// Bold weight.
    case bold
}

public extension UIFont {
    
    /**
     Creates a Source Sans Pro font at the specified size and weight.
     
     - parameter fontSize: The size of the font.
     - parameter weight:   The weight of the font.
     
     - returns: A Source Sans Pro `UIFont` at the specified size and weight.
     */
    public static func sourceSansProFont(ofSize fontSize: CGFloat, weight: FontWeight = .regular) -> UIFont {
        let fontName: String = {
            switch weight {
            case .regular:
                return "SourceSansPro-Regular"
            case .semibold:
                return "SourceSansPro-Semibold"
            case .bold:
                return "SourceSansPro-Bold"
            }
        }()
        
        if let fontURL = Bundle.pinpointKitBundle().url(forResource: fontName, withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        
        return UIFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
    
    /**
     Creates a Menlo font at regular weight and the specified size.
     
     - parameter fontSize: The size font.
     
     - returns: A `UIFont` representing Menlo Regular at the specified size.
     */
    public static func menloRegularFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Menlo-Regular", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
}
