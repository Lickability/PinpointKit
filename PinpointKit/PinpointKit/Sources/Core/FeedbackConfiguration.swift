//
//  FeedbackConfiguration.swift
//  Pods
//
//  Created by Michael Liberatore on 7/8/16.
//
//

import UIKit

/// Encapsulates configuration properties for all feedback to be sent.
public struct FeedbackConfiguration {
    
    /// Encapsulates body content of the feedback submission. Suitable for an email body.
    public struct Body {
        
        /// The initial body text of the message. The text is interpreted as either plain text or HTML depending on the value of `isHTML`.
        public var content: String
        
        /// `true` if `content` contains HTML or `false` if it is plain text.
        public var isHTML: Bool
        
        /// Initializes a new `Body`.
        ///
        /// - Parameters:
        ///   - content: The initial body text of the message. The text is interpreted as either plain text or HTML depending on the value of `isHTML`.
        ///   - isHTML: `true` if `content` contains HTML or `false` if it is plain text.
        public init(_ content: String, isHTML: Bool = false) {
            self.content = content
            self.isHTML = isHTML
        }
    }
    
    /// The value of the default parameter for `title` in the initializer.
    public static let DefaultTitle = "Bug Report"
    
    /// A file name without an extension for the screenshot or annotated screenshot.
    public var screenshotFileName: String
    
    /// The recipients of the feedback submission. Suitable for email recipients in the "To:" field.
    public var recipients: [String]?
    
    /// A short, optional title of the feedback submission. Suitable for an email subject.
    public var title: String?
    
    /// An optional body of the feedback submission.
    public var body: Body?
    
    /// A file name without an extension for the logs text file.
    public var logsFileName: String
    
    /// A dictionary of additional information provided by the application developer.
    public var additionalInformation: [String: AnyObject]?
    
    /// The modal presentation style for the feedback collection screen.
    public let presentationStyle: UIModalPresentationStyle
    
    /**
     Initializes a `FeedbackConfiguration` with optional default values.
     
     - parameter screenshotFileName:     The file name of the screenshot.
     - parameter recipients:             The recipients of the feedback submission.
     - parameter title:                  The title of the feedback.
     - parameter body:                   The default body text.
     - parameter logsFileName:           The file name of the logs text file.
     - parameter additionalInformation:  Any additional information you want to capture.
     - parameter presentationStyle:      The modal presentation style for the the feedback collection screen.
     */
    public init(screenshotFileName: String = "Screenshot",
                recipients: [String],
                title: String? = FeedbackConfiguration.DefaultTitle,
                body: Body? = nil,
                logsFileName: String = "logs",
                additionalInformation: [String: AnyObject]? = nil,
                presentationStyle: UIModalPresentationStyle = .fullScreen) {
        self.screenshotFileName = screenshotFileName
        self.recipients = recipients
        self.title = title
        self.body = body
        self.logsFileName = logsFileName
        self.additionalInformation = additionalInformation
        self.presentationStyle = presentationStyle
    }
}
