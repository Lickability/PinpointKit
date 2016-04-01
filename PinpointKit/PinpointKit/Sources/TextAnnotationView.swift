//
//  TextAnnotationView.swift
//  Pinpoint
//
//  Created by Brian Capps on 4/22/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

class TextAnnotationView: AnnotationView, UITextViewDelegate {
    static let TextViewInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    static let TextViewLineFragmentPadding: CGFloat = 5.0
    
    let textView: UITextView = {
        let storage = NSTextStorage()
        let manager = StrokeLayoutManager()
        manager.strokeColor = UIColor.whiteColor()
        manager.strokeWidth = 4.5
        
        let container = NSTextContainer(size: CGSize(width: 0, height: CGFloat.max))
        container.widthTracksTextView = true
        
        manager.addTextContainer(container)
        storage.addLayoutManager(manager)
        
        let textView = UITextView(frame: CGRectZero, textContainer: container)
        
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
            textView.frame = annotation.map { $0.frame } ?? CGRectZero
            originalTextViewFrame = textView.frame
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        
        textView.delegate = self
        textView.typingAttributes = textAttributes()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func tintColorDidChange() {
        textView.typingAttributes = {
            var attributes = self.textView.typingAttributes
            attributes[NSForegroundColorAttributeName] = self.tintColor
            return attributes
        }()
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let value = annotationFrame.map { CGRectContainsPoint($0, point) } ?? false
        return value
    }
        
    // MARK: - AnnotationView
    
    override func moveControlPoints(translation: CGPoint) {
        textView.frame = {
            var textViewFrame = self.textView.frame
            textViewFrame.origin = CGPoint(x: CGRectGetMinX(textViewFrame) + translation.x, y: CGRectGetMinY(textViewFrame) + translation.y)
            return textViewFrame
        }()
    }
    
    // MARK: - TextAnnotationView
    
    func textAttributes() -> [String: AnyObject] {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 5
        shadow.shadowColor = UIColor(white: 0.0, alpha: 1.0)
        shadow.shadowOffset = CGSizeZero
        
        return [
            NSFontAttributeName: self.dynamicType.font(),
            NSForegroundColorAttributeName: tintColor,
            NSShadowAttributeName: shadow,
            NSKernAttributeName: 1.3
        ]
    }
    
    class func font() -> UIFont {
        return UIFont.sourceSansProFontOfSize(32, weight: .Semibold)
    }
    
    class func minimumTextSize() -> CGSize {
        let width: CGFloat = 40.0
        let character = "." as NSString
        let size = character.boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font()], context: nil)
        return CGSize(width: width, height: size.height + TextViewInset.top + TextViewInset.bottom + TextViewLineFragmentPadding)
    }
    
    func updateTextViewFrame() {
        textView.frame = {
            var textViewFrame = self.textView.frame
            textViewFrame.size = self.textView.intrinsicContentSize()
            
            let distanceToEdgeOfView = CGRectGetMaxX(self.bounds) - CGRectGetMinX(textViewFrame)
            textViewFrame.size.width = min(CGRectGetWidth(textViewFrame), distanceToEdgeOfView)
            
            let minHeight: CGFloat
            
            if let originalTextViewFrame = self.originalTextViewFrame {
                textViewFrame.size.width = max(CGRectGetWidth(textViewFrame), CGRectGetWidth(originalTextViewFrame))
                minHeight = CGRectGetHeight(originalTextViewFrame)
            } else {
                minHeight = self.dynamicType.minimumTextSize().height
            }
            
            let size = CGSize(width: CGRectGetWidth(textViewFrame), height: CGFloat.max)
            
            textViewFrame.size.height = max(self.textView.sizeThatFits(size).height, minHeight)
            
            return textViewFrame
        }()
    }
    
    func beginEditing() {
        textView.selectable = true
        textView.editable = true
        textView.becomeFirstResponder()
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        updateTextViewFrame()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {        
        textView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = tintColor.colorWithAlphaComponent(self.dynamicType.BorderAlpha).CGColor
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.selectable = false
        textView.editable = false
        
        textView.backgroundColor = UIColor.clearColor()
        textView.layer.borderWidth = 0
        textView.layer.borderColor = nil
    }
}
