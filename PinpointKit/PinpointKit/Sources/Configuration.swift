//
//  Configuration.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/**
 *  A struct that contains configuration information for the behavior and appearance of PinpointKit.
 */
public struct Configuration {
    
    /**
     *  A struct containing information about the appearance of displayed components.
     */
    public struct Appearance {
        
        /// The tint color of PinpointKit views used to style interactive and selected elements.
        let tintColor: UIColor?
        
        // The fill color for annotations. If none is supplied, the `tintColor` of the relevant view will be used.
        let annotationFillColor: UIColor?
        
        /// The stroke color for annotations.
        let annotationStrokeColor: UIColor
        
        /**
         Initializes an `Appearance` object with a optional annotation color properties.
         
         - parameter annotationFillColor:   The fill color for annotations. If none is supplied, the `tintColor` of the relevant view will be used.
         - parameter annotationStrokeColor: The stroke color for annotations.
         
         - returns: A fully initialized `Appearance` object.
         */
        public init(tintColor: UIColor? = UIColor.pinpointOrangeColor(), annotationFillColor: UIColor? = nil, annotationStrokeColor: UIColor = .whiteColor()) {
            self.tintColor = tintColor
            self.annotationFillColor = annotationFillColor
            self.annotationStrokeColor = annotationStrokeColor
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
        
        /// A hint to the user on how to edit the screenshot from the feedback screen.
        let feedbackEditHint: String?
        
        /// The title of a cell that allows the user to toggle log collection.
        let logCollectionPermissionTitle: String
        
        /// Initializes an `InterfaceText` with custom values, using a default if a particular property is unspecified.
        public init(feedbackCollectorTitle: String? = NSLocalizedString("Report a Bug", comment: "Title of a view that reports a bug"),
            feedbackSendButtonTitle: String = NSLocalizedString("Send", comment: "A button that sends feedback."),
            feedbackCancelButtonTitle: String? = nil,
            feedbackEditHint: String? = NSLocalizedString("Tap the screenshot to annotate.", comment: "A hint on how to edit the screenshot"),
            logCollectionPermissionTitle: String = NSLocalizedString("Include Console Log", comment: "Title of a button asking the user to include system logs")) {
                self.feedbackCollectorTitle = feedbackCollectorTitle
                self.feedbackSendButtonTitle = feedbackSendButtonTitle
                self.feedbackCancelButtonTitle = feedbackCancelButtonTitle
                self.feedbackEditHint = feedbackEditHint
                self.logCollectionPermissionTitle = logCollectionPermissionTitle
        }
    }
    
    /// A struct containing information about the appearance of displayed components.
    let appearance: Appearance
    
    let interfaceText: InterfaceText
    
    /// An optional type that collects logs to be displayed and sent with feedback.
    let logCollector: LogCollector?
    
    let logViewer: LogViewer?
    
    /// A feedback collector that obtains the feedback to send.
    let feedbackCollector: FeedbackCollector
    
    /// An editor that allows annotation of images.
    let editor: Editor
    
    /// A sender that allows sending the feedback outside the framework.
    let sender: Sender
    
    /**
     Initializes a `Configuration` object with optionally customizable appearance and behaviors.
     
     - parameter appearance:        A struct containing information about the appearance of displayed components.
     - parameter logCollector:      An optional type that collects logs to be displayed and sent with feedback.
     - parameter feedbackCollector: A feedback collector that obtains the feedback, by default in the form of annotated screenshots, to send.
     - parameter editor:            An editor that allows annotation of images.
     - parameter sender:            A sender that allows sending the feedback outside the framework.
     
     - returns: A fully initialized `Configuration` object.
     */
    public init(appearance: Appearance = Appearance(),
        interfaceText: InterfaceText = InterfaceText(),
        logCollector: LogCollector? = SystemLogCollector(),
        logViewer: LogViewer? = BasicLogViewController(),
        feedbackCollector: FeedbackCollector = FeedbackNavigationController(),
        editor: Editor = EditImageViewController(),
        sender: Sender = MailSender()) {
            
            self.appearance = appearance
            self.interfaceText = interfaceText
            self.logCollector = logCollector
            self.logViewer = logViewer
            self.feedbackCollector = feedbackCollector
            self.editor = editor
            self.sender = sender
            
            self.feedbackCollector.configuration = self
    }
}
