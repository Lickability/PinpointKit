//
//  TextAnnotationView.swift
//  Pinpoint
//
//  Created by Brian Capps on 4/22/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The default text annotation view.
public class TextAnnotationView: AnnotationView, UITextViewDelegate {
    private static let TextViewInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    private static let TextViewLineFragmentPadding: CGFloat = 5.0
    
    /// The text view that is used to display the text of the annotation.
    let textView: UITextView = {
        let storage = NSTextStorage()
        let manager = StrokeLayoutManager()
        manager.strokeWidth = 4.5
        
        let container = NSTextContainer(size: CGSize(width: 0, height: CGFloat.max))
        container.widthTracksTextView = true
        
        manager.addTextContainer(container)
        storage.addLayoutManager(manager)
        
        let textView = UITextView(frame: CGRect.zero, textContainer: container)
        
        textView.spellCheckingType = .No
        textView.scrollEnabled = false
        textView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        textView.textContainerInset = TextViewInset
        textView.textContainer.lineFragmentPadding = TextViewLineFragmentPadding
        
        return textView
    }()
    
    override var annotationFrame: CGRect? {
        return textView.frame
    }
    
    private(set) var originalTextViewFrame: CGRect?
    
    var annotation: Annotation? {
        didSet {
            textView.frame = annotation?.frame ?? CGRect.zero
            originalTextViewFrame = textView.frame
            (textView.layoutManager as? StrokeLayoutManager)?.strokeColor = annotation?.strokeColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        
        textView.delegate = self
        textView.typingAttributes = textAttributes
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override public func tintColorDidChange() {
        textView.typingAttributes = {
            var attributes = self.textView.typingAttributes
            attributes[NSForegroundColorAttributeName] = self.tintColor
            return attributes
        }()
    }
    
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return annotationFrame?.contains(point) ?? false
    }
        
    // MARK: - AnnotationView
    
    override func moveControlPoints(translation: CGPoint) {
        textView.frame = {
            var textViewFrame = self.textView.frame
            textViewFrame.origin = CGPoint(x: textViewFrame.minX + translation.x, y: textViewFrame.minY + translation.y)
            return textViewFrame
        }()
    }
    
    // MARK: - TextAnnotationView
    
    /// The attributes of the text to use for an `NSAttributedString`.
    var textAttributes: [String: AnyObject] {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 5
        shadow.shadowColor = UIColor(white: 0.0, alpha: 1.0)
        shadow.shadowOffset = CGSize.zero
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: tintColor,
            NSShadowAttributeName: shadow,
            NSKernAttributeName: 1.3
        ]
    }
    
    private var font: UIFont {
        return UITextView.appearanceWhenContainedInInstancesOfClasses([TextAnnotationView.self]).font ?? UIFont.systemFontOfSize(32)
    }
    
    /// The minimum text size for the annotation view.
    var minimumTextSize: CGSize {
        let width: CGFloat = 40.0
        let character = "." as NSString
        let textFont = textAttributes[NSFontAttributeName] ?? font
        
        let size = character.boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: textFont], context: nil)
        return CGSize(width: width, height: size.height + TextAnnotationView.TextViewInset.top + TextAnnotationView.TextViewInset.bottom + TextAnnotationView.TextViewLineFragmentPadding)
    }
    
    private func updateTextViewFrame() {
        textView.frame = {
            var textViewFrame = self.textView.frame
            textViewFrame.size = self.textView.intrinsicContentSize()
            
            let distanceToEdgeOfView = self.bounds.maxX - textViewFrame.minX
            textViewFrame.size.width = min(textViewFrame.width, distanceToEdgeOfView)
            
            let minHeight: CGFloat
            
            if let originalTextViewFrame = self.originalTextViewFrame {
                textViewFrame.size.width = max(textViewFrame.width, originalTextViewFrame.width)
                minHeight = originalTextViewFrame.height
            } else {
                minHeight = minimumTextSize.height
            }
            
            let size = CGSize(width: textViewFrame.width, height: CGFloat.max)
            
            textViewFrame.size.height = max(textView.sizeThatFits(size).height, minHeight)
            
            return textViewFrame
        }()
    }
    
    /**
     Tells the internal text view to begin editing.
     */
    func beginEditing() {
        textView.selectable = true
        textView.editable = true
        textView.becomeFirstResponder()
    }
    
    // MARK: - UITextViewDelegate
    
    public func textViewDidChange(textView: UITextView) {
        updateTextViewFrame()
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        textView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = tintColor.colorWithAlphaComponent(self.dynamicType.BorderAlpha).CGColor
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        textView.selectable = false
        textView.editable = false
        
        textView.backgroundColor = UIColor.clearColor()
        textView.layer.borderWidth = 0
        textView.layer.borderColor = nil
    }
}
