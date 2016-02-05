//
//  Configuration.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

/**
 *  A struct that contains configuration information for the behavior and appearance of PinpointKit.
 */
struct Configuration {
    
    /**
     *  A struct containing information about the appearance of displayed components.
     */
    struct Appearance {
        
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
        init(annotationFillColor: UIColor? = nil, annotationStrokeColor: UIColor = .whiteColor()) {
            self.annotationFillColor = annotationFillColor
            self.annotationStrokeColor = annotationStrokeColor
        }
    }
    
    let appearance: Appearance
    
    let logCollector: LogCollector?
    let feedbackCollector: FeedbackCollector
    let editor: Editor
    let sender: Sender
    
    /**
     Initializes a `Configuration` object with optionally customizable appearance and behaviors.
     
     - parameter appearance:        A struct containing information about the appearance of displayed components.
     - parameter logCollector:      An optional type that collects logs to be displayed and sent along with feedback.
     - parameter feedbackCollector: A feedback collector that obtains the feedback, by default in the form of annotated screenshots, to send.
     - parameter editor:            An editor that allows annotation of images.
     - parameter sender:            A sender that allows sending the feedback outside the framework.
     
     - returns: A fully initialized `Configuration` object.
     */
    init(appearance: Appearance = Appearance(), logCollector: LogCollector? = SystemLogCollector(), feedbackCollector: FeedbackCollector = FeedbackViewController(), editor: Editor = EditImageViewController(), sender: Sender = MailSender()) {
        self.appearance = appearance
        self.logCollector = logCollector
        self.feedbackCollector = feedbackCollector
        self.editor = editor
        self.sender = sender
    }
}