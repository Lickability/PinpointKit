//
//  FeedbackConfiguration.swift
//  Pods
//
//  Created by Michael Liberatore on 7/8/16.
//
//

/// Encapsulates configuration properties for all feedback to be sent.
public struct FeedbackConfiguration {
    
    /// The value of the default parameter for `title` in the initializer.
    public static let DefaultTitle = "Bug Report"
    
    /// A file name without an extension for the screenshot or annotated screenshot.
    public var screenshotFileName: String
    
    /// The recipients of the feedback submission. Suitable for email recipients in the "To:" field.
    public var recipients: [String]?
    
    /// A short, optional title of the feedback submission. Suitable for an email subject.
    public var title: String?
    
    /// An optional plain-text body of the feedback submission. Suitable for an email body.
    public var body: String?
    
    /// A file name without an extension for the logs text file.
    public var logsFileName: String
    
    /// A dictionary of additional information provided by the application developer.
    public var additionalInformation: [String: AnyObject]?
    
    /**
     Initializes a `FeedbackConfiguration` with optional default values.
     
     - parameter screenshotFileName:     The file name of the screenshot.
     - parameter recipients:             The recipients of the feedback submission.
     - parameter title:                  The title of the feedback.
     - parameter body:                   The default body text.
     - parameter logsFileName:           The file name of the logs text file.
     - parameter additionalInformation:  Any additional information you want to capture.
     */
    public init(screenshotFileName: String = "Screenshot",
                recipients: [String],
                title: String? = FeedbackConfiguration.DefaultTitle,
                body: String? = nil,
                logsFileName: String = "logs",
                additionalInformation: [String: AnyObject]? = nil) {
        self.screenshotFileName = screenshotFileName
        self.recipients = recipients
        self.title = title
        self.body = body
        self.logsFileName = logsFileName
        self.additionalInformation = additionalInformation
    }
}
