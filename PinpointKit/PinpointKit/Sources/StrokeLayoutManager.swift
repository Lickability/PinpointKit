//
//  StrokeLayoutManager.swift
//  Pinpoint
//
//  Created by Brian Capps on 4/23/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// A subclass of `NSLayoutManager` that handles drawing the stroke.
final class StrokeLayoutManager: NSLayoutManager {
    
    /// The color to display as a stroke around the text.
    var strokeColor: UIColor?
    
    /// The width of the stroke to display around the text.
    var strokeWidth: CGFloat?
    
    override func drawGlyphsForGlyphRange(glyphsToShow: NSRange, atPoint origin: CGPoint) {
        let context = UIGraphicsGetCurrentContext()
        
        let firstIndex = characterIndexForGlyphAtIndex(glyphsToShow.location)
        let attributes = textStorage?.attributesAtIndex(firstIndex, effectiveRange: nil)
        let shadow = attributes?[NSShadowAttributeName] as? NSShadow
        let shouldRenderTransparencyLayer = strokeColor != nil && strokeWidth != nil && shadow != nil
        
        if let shadow = shadow where shouldRenderTransparencyLayer {
            // Applies the shadow to the entire stroke as one layer, insead of overlapping per-character.
            CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor?.CGColor)
            CGContextBeginTransparencyLayer(context, nil)
        }
        
        super.drawGlyphsForGlyphRange(glyphsToShow, atPoint: origin)
        
        if shouldRenderTransparencyLayer {
            CGContextEndTransparencyLayer(context)
        }
    }
    
    override func showCGGlyphs(glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, matrix textMatrix: CGAffineTransform, attributes: [String : AnyObject], inContext graphicsContext: CGContext) {
        var textAttributes = attributes
        
        if let strokeColor = strokeColor, strokeWidth = strokeWidth {
            // Remove the shadow. It'll all be drawn at once afterwards.
            textAttributes[NSShadowAttributeName] = nil
            CGContextSetShadowWithColor(graphicsContext, CGSize.zero, 0, nil)
            
            CGContextSaveGState(graphicsContext)
            
            strokeColor.setStroke()
            
            CGContextSetLineWidth(graphicsContext, strokeWidth)
            CGContextSetLineJoin(graphicsContext, .Miter)
            
            CGContextSetTextDrawingMode(graphicsContext, .FillStroke)
            
            super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, matrix: textMatrix, attributes: textAttributes, inContext: graphicsContext)
            
            // Due to a bug in iOS 7, kCGTextFillStroke will never have the correct fill color, so we must draw the string twice: once for stroke and once for fill. http://stackoverflow.com/questions/18894907/why-cgcontextsetrgbstrokecolor-isnt-working-on-ios7
            
            CGContextRestoreGState(graphicsContext)
            CGContextSetTextDrawingMode(graphicsContext, .Fill)
        }
        
        super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, matrix: textMatrix, attributes: textAttributes, inContext: graphicsContext)
    }
}
