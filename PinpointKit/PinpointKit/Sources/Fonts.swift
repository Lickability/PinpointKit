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
        
        if let font = (NSBundle(forClass: PinpointKit.self).URLForResource(fontName, withExtension: "ttf").flatMap {
            return NSData(contentsOfURL: $0)
        }.flatMap {
            return CGDataProviderCreateWithCFData($0)
        }.flatMap {
            return CGFontCreateWithDataProvider($0)
        }) {
            CTFontManagerRegisterGraphicsFont(font, nil)
        }
        
        return UIFont(name: fontName, size: fontSize)!
    }
}
