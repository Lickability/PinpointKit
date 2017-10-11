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
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let context = UIGraphicsGetCurrentContext()
        
        let firstIndex = characterIndexForGlyph(at: glyphsToShow.location)
        let attributes = textStorage?.attributes(at: firstIndex, effectiveRange: nil)
        let shadow = attributes?[NSAttributedStringKey.shadow] as? NSShadow
        let shouldRenderTransparencyLayer = strokeColor != nil && strokeWidth != nil && shadow != nil
        
        if let shadow = shadow, shouldRenderTransparencyLayer {
            // Applies the shadow to the entire stroke as one layer, insead of overlapping per-character.
            context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as? UIColor)?.cgColor)
            context?.beginTransparencyLayer(auxiliaryInfo: nil)
        }
        
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        
        if shouldRenderTransparencyLayer {
            context?.endTransparencyLayer()
        }
    }
    
    override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, matrix textMatrix: CGAffineTransform, attributes: [NSAttributedStringKey : Any], in graphicsContext: CGContext) {
        var textAttributes = attributes
        
        defer {
            super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, matrix: textMatrix, attributes: textAttributes, in: graphicsContext)
        }
        
        guard let strokeColor = self.strokeColor else { return }
        guard let strokeWidth = self.strokeWidth else { return }
        
        // Remove the shadow. It'll all be drawn at once afterwards.
        textAttributes[NSAttributedStringKey.shadow] = nil
        graphicsContext.setShadow(offset: CGSize.zero, blur: 0, color: nil)
        
        graphicsContext.saveGState()
        
        strokeColor.setStroke()
        
        graphicsContext.setLineWidth(strokeWidth)
        graphicsContext.setLineJoin(.miter)
        
        graphicsContext.setTextDrawingMode(.fillStroke)
        
        super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, matrix: textMatrix, attributes: textAttributes, in: graphicsContext)
        
        // Due to a bug introduced in iOS 7, kCGTextFillStroke will never have the correct fill color, so we must draw the string twice: once for stroke and once for fill. http://stackoverflow.com/questions/18894907/why-cgcontextsetrgbstrokecolor-isnt-working-on-ios7
        
        graphicsContext.restoreGState()
        graphicsContext.setTextDrawingMode(.fill)
    }
}
