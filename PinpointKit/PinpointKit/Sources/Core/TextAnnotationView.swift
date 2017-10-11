//
//  TextAnnotationView.swift
//  Pinpoint
//
//  Created by Brian Capps on 4/22/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// The default text annotation view.
open class TextAnnotationView: AnnotationView, UITextViewDelegate {
    private static let TextViewInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    private static let TextViewLineFragmentPadding: CGFloat = 5.0
    
    /// The text view that is used to display the text of the annotation.
    let textView: UITextView = {
        let storage = NSTextStorage()
        let manager = StrokeLayoutManager()
        manager.strokeWidth = 4.5
        
        let container = NSTextContainer(size: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        
        manager.addTextContainer(container)
        storage.addLayoutManager(manager)
        
        let textView = UITextView(frame: CGRect.zero, textContainer: container)
        
        textView.spellCheckingType = .no
        textView.isScrollEnabled = false
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
    
    override open func tintColorDidChange() {
        textView.typingAttributes = {
            var attributes = self.textView.typingAttributes
            attributes[NSAttributedStringKey.foregroundColor.rawValue] = self.tintColor
            return attributes
        }()
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return annotationFrame?.contains(point) ?? false
    }
        
    // MARK: - AnnotationView
    
    override func move(controlPointsBy translationAmount: CGPoint) {
        textView.frame = {
            var textViewFrame = self.textView.frame
            textViewFrame.origin = CGPoint(x: textViewFrame.minX + translationAmount.x, y: textViewFrame.minY + translationAmount.y)
            return textViewFrame
        }()
    }
    
    // MARK: - TextAnnotationView
    
    /// The attributes of the text to use for an `NSAttributedString`.
    var textAttributes: [String: AnyObject] = [:] {
        didSet {
            textAttributes[NSAttributedStringKey.font.rawValue] = font
            textView.typingAttributes = textAttributes
        }
    }
    
    private var font: UIFont {
        return UITextView.appearance(whenContainedInInstancesOf: [TextAnnotationView.self]).font ?? .systemFont(ofSize: 32)
    }
    
    /// The minimum text size for the annotation view.
    var minimumTextSize: CGSize {
        let width: CGFloat = 40.0
        let character = "." as NSString
        let textFont = textAttributes[NSAttributedStringKey.font.rawValue] ?? font
        
        let size = character.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: textFont], context: nil)
        return CGSize(width: width, height: size.height + TextAnnotationView.TextViewInset.top + TextAnnotationView.TextViewInset.bottom + TextAnnotationView.TextViewLineFragmentPadding)
    }
    
    private func updateTextViewFrame() {
        textView.frame = {
            var textViewFrame = self.textView.frame
            textViewFrame.size = self.textView.intrinsicContentSize
            
            let distanceToEdgeOfView = self.bounds.maxX - textViewFrame.minX
            textViewFrame.size.width = min(textViewFrame.width, distanceToEdgeOfView)
            
            let minHeight: CGFloat
            
            if let originalTextViewFrame = self.originalTextViewFrame {
                textViewFrame.size.width = max(textViewFrame.width, originalTextViewFrame.width)
                minHeight = originalTextViewFrame.height
            } else {
                minHeight = minimumTextSize.height
            }
            
            let size = CGSize(width: textViewFrame.width, height: CGFloat.greatestFiniteMagnitude)
            
            textViewFrame.size.height = max(textView.sizeThatFits(size).height, minHeight)
            
            return textViewFrame
        }()
    }
    
    /**
     Tells the internal text view to begin editing.
     */
    func beginEditing() {
        textView.isSelectable = true
        textView.isEditable = true
        textView.becomeFirstResponder()
    }
    
    // MARK: - UITextViewDelegate
    
    open func textViewDidChange(_ textView: UITextView) {
        updateTextViewFrame()
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = tintColor.withAlphaComponent(type(of: self).BorderAlpha).cgColor
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        textView.isSelectable = false
        textView.isEditable = false
        
        textView.backgroundColor = .clear
        textView.layer.borderWidth = 0
        textView.layer.borderColor = nil
    }
}
