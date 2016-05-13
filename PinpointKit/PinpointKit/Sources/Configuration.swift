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
    
    /// A struct containing information about the appearance of displayed components.
    var appearance: InterfaceCustomization.Appearance? {
        return feedbackCollector.interfaceCustomization?.appearance
    }
    
    ///  A struct containing user-facing strings displayed in the interface.
    var interfaceText: InterfaceCustomization.InterfaceText? {
        return feedbackCollector.interfaceCustomization?.interfaceText
    }

    /// An optional type that collects logs to be displayed and sent with feedback.
    var logCollector: LogCollector? {
        return feedbackCollector.logCollector
    }
    
    /// An optional type that allows the user to view logs before sending feedback.
    var logViewer: LogViewer? {
        return feedbackCollector.logViewer
    }
    
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
    public init(appearance: InterfaceCustomization.Appearance = InterfaceCustomization.Appearance(),
        interfaceText: InterfaceCustomization.InterfaceText = InterfaceCustomization.InterfaceText(),
        logCollector: LogCollector? = SystemLogCollector(),
        logViewer: LogViewer? = BasicLogViewController(),
        feedbackCollector: FeedbackCollector = FeedbackNavigationController(),
        editor: Editor = EditImageViewController(),
        sender: Sender = MailSender()) {
            self.feedbackCollector = feedbackCollector
            self.editor = editor
            self.sender = sender
        
            let interfaceCustomization = InterfaceCustomization(interfaceText: interfaceText, appearance: appearance)

            self.feedbackCollector.interfaceCustomization = interfaceCustomization
            self.feedbackCollector.logCollector = logCollector
        
            self.feedbackCollector.logViewer = logViewer
            self.feedbackCollector.logViewer?.interfaceCustomization = interfaceCustomization
    }
}
