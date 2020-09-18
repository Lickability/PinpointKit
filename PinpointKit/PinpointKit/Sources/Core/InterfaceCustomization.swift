//
//  InterfaceCustomization.swift
//  PinpointKit
//
//  Created by Andrew Harrison on 5/13/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A struct that supplies customized interface text and appearance values.
public struct InterfaceCustomization {
    let interfaceText: InterfaceText
    let appearance: Appearance
    
    /**
     Initializes an InterfaceCustomization object.
     
     - parameter interfaceText: The interfact text customization.
     - parameter appearance:    The appearance customization.     
     */
    public init(interfaceText: InterfaceText = InterfaceText(), appearance: Appearance = Appearance()) {
        self.interfaceText = interfaceText
        self.appearance = appearance
    }
    
    /**
     *  A struct containing information about the appearance of displayed components.
     */
    public struct Appearance {
        /// The status bar style of PinpointKit.
        let statusBarStyle: UIStatusBarStyle
        
        /// The tint color of PinpointKit views used to style interactive and selected elements.
        let tintColor: UIColor?
        
        /// The fill color for annotations. If none is supplied, the `tintColor` of the relevant view will be used.
        let annotationFillColor: UIColor?
        
        /// The text attributes for annotations. Note that `NSForegroundColorAttributeName` can only be customized using `annotationFillColor`.
        let annotationTextAttributes: [NSAttributedString.Key: AnyObject]
        
        /// The stroke color for annotations.
        let annotationStrokeColor: UIColor

        /// The font used for navigation titles.
        let navigationTitleColor: UIColor
        
        /// The font used for navigation titles.
        let navigationTitleFont: UIFont
        
        /// The font used for the select screenshot button used for `.limited` photo library access.
        let selectScreenshotButtonFont: UIFont
        
        /// The font used for the button that sends feedback.
        let feedbackSendButtonFont: UIFont
        
        /// The font used for the button that cancels feedback collection.
        let feedbackCancelButtonFont: UIFont
        
        /// The font used for the hint to the user on how to edit the screenshot from the feedback screen.
        let feedbackEditHintFont: UIFont
        
        /// The font used for the back button that takes the user back to the initial feedback collection screen.
        let feedbackBackButtonFont: UIFont

        /// The font used for the title of the cell that allows the user to toggle log collection.
        let logCollectionPermissionFont: UIFont
        
        /// The font used for displaying logs.
        let logFont: UIFont
        
        /// The font used for the text annotation tool segment in the editor.
        let editorTextAnnotationSegmentFont: UIFont
        
        /// The font used for the dismiss button in the editor displayed while editing a text annotation.
        let editorTextAnnotationDismissButtonFont: UIFont
        
        /// The font used for the done button in the editor to finish editing the image.
        let editorDoneButtonFont: UIFont
        
        /**
         Initializes an `Appearance` object with a optional annotation color properties.

         - parameter statusBarStyle:                        The status bar style of PinpointKit.
         - parameter tintColor:                             The tint color of the interface.
         - parameter annotationFillColor:                   The fill color for annotations. If none is supplied, the `tintColor` of the relevant view will be used.
         - parameter annotationStrokeColor:                 The stroke color for annotations.
         - parameter annotationTextAttributes:              The text attributes for annotations.
         - parameter navigationTitleColor:                  The color used for navigation titles.
         - parameter navigationTitleFont:                   The font used for navigation titles.
         - parameter selectScreenshotButtonFont:            The font used for the select screenshot button.
         - parameter feedbackSendButtonFont:                The font used for the button that sends feedback.
         - parameter feedbackCancelButtonFont:              The font used for the button that cancels feedback collection.
         - parameter feedbackEditHintFont:                  The font used for the hint to the user on how to edit the screenshot from the feedback screen.
         - parameter feedbackBackButtonFont:                The font used for the back button that takes the user back to the initial feedback collection screen.
         - parameter logCollectionPermissionFont:           The font used for the title of the cell that allows the user to toggle log collection.
         - parameter logFont:                               The font used for displaying logs.
         - parameter editorTextAnnotationSegmentFont:       The font used for the text annotation tool segment in the editor.
         - parameter editorTextAnnotationDismissButtonFont: The font used for the dismiss button in the editor displayed while editing a text annotation.
         - parameter editorDoneButtonFont:                  The font used for the done button in the editor to finish editing the image.
         */
        public init(statusBarStyle: UIStatusBarStyle = .default,
                    tintColor: UIColor? = .pinpointOrange(),
                    annotationFillColor: UIColor? = nil,
                    annotationStrokeColor: UIColor = .white,
                    annotationTextAttributes: [NSAttributedString.Key: AnyObject]? = nil,
                    navigationTitleColor: UIColor = Self.defaultNavigationTitleColor,
                    navigationTitleFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold),
                    selectScreenshotButtonFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold),
                    feedbackSendButtonFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold),
                    feedbackCancelButtonFont: UIFont = .sourceSansProFont(ofSize: 19),
                    feedbackEditHintFont: UIFont = .sourceSansProFont(ofSize: 14),
                    feedbackBackButtonFont: UIFont = .sourceSansProFont(ofSize: 19),
                    logCollectionPermissionFont: UIFont = .sourceSansProFont(ofSize: 19),
                    logFont: UIFont = .menloRegularFont(ofSize: 10),
                    editorTextAnnotationSegmentFont: UIFont = .sourceSansProFont(ofSize: 18),
                    editorTextAnnotationDismissButtonFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold),
                    editorDoneButtonFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold)) {
            self.statusBarStyle = statusBarStyle
            self.tintColor = tintColor
            self.annotationFillColor = annotationFillColor
            self.annotationStrokeColor = annotationStrokeColor
            self.navigationTitleColor = navigationTitleColor
            
            // Custom annotation text attributes
            if var customAnnotationTextAttributes = annotationTextAttributes {
                // Ensure annotation font is set, if not use default font
                if customAnnotationTextAttributes[.font] == nil {
                    customAnnotationTextAttributes[.font] = type(of: self).DefaultAnnotationTextFont
                }
                self.annotationTextAttributes = customAnnotationTextAttributes
            } else {
                self.annotationTextAttributes = type(of: self).defaultTextAnnotationAttributes
            }
            
            self.logFont = logFont
            self.navigationTitleFont = navigationTitleFont
            self.selectScreenshotButtonFont = selectScreenshotButtonFont
            self.feedbackSendButtonFont = feedbackSendButtonFont
            self.feedbackCancelButtonFont = feedbackCancelButtonFont
            self.feedbackEditHintFont = feedbackEditHintFont
            self.feedbackBackButtonFont = feedbackBackButtonFont
            self.logCollectionPermissionFont = logCollectionPermissionFont
            self.editorTextAnnotationSegmentFont = editorTextAnnotationSegmentFont
            self.editorTextAnnotationDismissButtonFont = editorTextAnnotationDismissButtonFont
            self.editorDoneButtonFont = editorDoneButtonFont
        }
        
        /// A default color to use for text within a navigation bar. Defaults to `UIColor.label` on iOS 13+ and `UIColor.darkText` on earlier versions.
        public static var defaultNavigationTitleColor: UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .darkText
            }
        }
    }
    
    /**
     *  A struct containing user-facing strings for display in the interface.
     */
    public struct InterfaceText {
        
        /// The title of the feedback collection screen.
        let feedbackCollectorTitle: String?
        
        /// The title of a button that sends feedback.
        let feedbackSendButtonTitle: String
        
        /// The title of a button that cancels feedback collection. Setting this property to `nil` uses a default value.
        let feedbackCancelButtonTitle: String?
        
        /// The title of a back button that takes the user back to the initial feedback collection screen. Setting this property to `nil` uses a default value.
        let feedbackBackButtonTitle: String?
        
        /// A hint to the user on how to edit the screenshot from the feedback screen.
        let feedbackEditHint: String?
        
        /// A title to use for the select screenshot button.
        let selectScreenshotButtonTitle: String
        
        /// The title of the log collection screen.
        let logCollectorTitle: String?
        
        /// The title of a cell that allows the user to toggle log collection.
        let logCollectionPermissionTitle: String
        
        ///  The title of a button that cancels text editing.
        let textEditingDismissButtonTitle: String
        
        ///  The title of a button that ends editing of the image.
        let editorDoneButtonTitle: String
        
        /**
         Initializes an `InterfaceText` with custom values, using a default if a particular property is unspecified.
         
         - parameter feedbackCollectorTitle:        The title of the feedback collector.
         - parameter feedbackSendButtonTitle:       The title of the send button.
         - parameter feedbackCancelButtonTitle:     The title of the cancel button.
         - parameter feedbackBackButtonTitle:       The title of the back button.
         - parameter feedbackEditHint:              The hint to show during editing.
         - parameter selectScreenshotButtonTitle:   The title of the select screenshot button.
         - parameter logCollectorTitle:             The title of the log collector.
         - parameter logCollectionPermissionTitle:  The title of the permission button.
         - parameter textEditingDismissButtonTitle: The title of the text editing dismiss button.
         - parameter editorDoneButtonTitle:         The title of a button that ends editing of the image.
         */
        public init(feedbackCollectorTitle: String? = NSLocalizedString("Report a Bug", comment: "Title of a view that reports a bug"),
                    feedbackSendButtonTitle: String = NSLocalizedString("Send", comment: "A button that sends feedback."),
                    feedbackCancelButtonTitle: String? = nil,
                    feedbackBackButtonTitle: String? = NSLocalizedString("Report", comment: "Back button title of a view that reports a bug"),
                    feedbackEditHint: String? = NSLocalizedString("Tap the screenshot to annotate.", comment: "A hint on how to edit the screenshot"),
                    selectScreenshotButtonTitle: String = NSLocalizedString("Select Screenshot…", comment: "A button that allows screenshot selection from the photo library."),
                    logCollectorTitle: String? = NSLocalizedString("Console Log", comment: "Title of a view that collects logs"),
                    logCollectionPermissionTitle: String = NSLocalizedString("Include Console Log", comment: "Title of a button asking the user to include system logs"),
                    textEditingDismissButtonTitle: String = NSLocalizedString("Dismiss", comment: "Title of a button that dismisses text editing"),
                    editorDoneButtonTitle: String = NSLocalizedString("Done", comment: "Title of a button that finishes editing")) {
            self.feedbackCollectorTitle = feedbackCollectorTitle
            self.feedbackSendButtonTitle = feedbackSendButtonTitle
            self.feedbackCancelButtonTitle = feedbackCancelButtonTitle
            self.feedbackBackButtonTitle = feedbackBackButtonTitle
            self.feedbackEditHint = feedbackEditHint
            self.selectScreenshotButtonTitle = selectScreenshotButtonTitle
            self.logCollectorTitle = logCollectorTitle
            self.logCollectionPermissionTitle = logCollectionPermissionTitle
            self.textEditingDismissButtonTitle = textEditingDismissButtonTitle
            self.editorDoneButtonTitle = editorDoneButtonTitle
        }
    }
}

private extension InterfaceCustomization.Appearance {
    
    static var defaultTextAnnotationAttributes: [NSAttributedString.Key: AnyObject] {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 5
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = .zero

        return [.font: DefaultAnnotationTextFont, .shadow: shadow, .kern: 1.3 as NSNumber]
    }
    
    static let DefaultAnnotationTextFont = UIFont.sourceSansProFont(ofSize: 32, weight: .semibold)
}
