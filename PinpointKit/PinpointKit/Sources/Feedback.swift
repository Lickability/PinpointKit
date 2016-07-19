//
//  Feedback.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A struct containing user feedback on an application.
public struct Feedback {
    
    /// An enum with assocated values that represents the screenshot.
    public enum ScreenshotType {
        /// The original, un-annotated screenshot.
        case Original(image: UIImage)
        
        /// An annotated screenshot.
        case Annotated(image: UIImage)
        
        /// Both the original and annotated screenshot.
        case Combined(originalImage: UIImage, annotatedImage: UIImage)
        
        /// Returns an image of the screenshot preferring the annotated image.
        public var preferredImage: UIImage {
            switch self {
            case let Original(image):
                return image
            case let Annotated(image):
                return image
            case let Combined(_, annotatedImage):
                return annotatedImage
            }
        }
    }
    
    /// A substructure containing information about the application and its environment.
    public struct ApplicationInformation {
        /// The application’s marketing version.
        public let version: String?
        
        /// The application’s build number.
        public let build: String?
        
        /// The application’s display name.
        public let name: String?
        
        /// The application’s bundle identifer.
        public let bundleIdentifer: String?
        
        /// The operating system version of the OS in which the application is running.
        public let operatingSystemVersion: NSOperatingSystemVersion?
    }
    
    /// A screenshot of the screen the feedback relates to.
    public let screenshot: ScreenshotType
    
    /// A file name without an extension for the screenshot or annotated screenshot.
    public let screenshotFileName: String
    
    /// The recipients of the feedback submission. Suitable for email recipients in the "To:" field.
    public let recipients: [String]?
    
    /// A short, optional title of the feedback submission. Suitable for an email subject.
    public let title: String?
    
    /// An optional plain-text body of the feedback submission. Suitable for an email body.
    public let body: String?
    
    /// An optional collection of log strings.
    public let logs: [String]?
    
    /// A file name without an extension for the logs text file.
    public let logsFileName: String
    
    /// A dictionary of additional information provided by the application developer.
    public let additionalInformation: [String: AnyObject]?
    
    /// A struct containing information about the application and its environment.
    public let applicationInformation: ApplicationInformation?
    
    /**
     Initializes a `Feedback` with optional default values.
     
     - parameter screenshot:             The type of screenshot in the feedback.
     - parameter screenshotFileName:     The file name of the screenshot.
     - parameter recipients:             The recipients of the feedback submission.
     - parameter title:                  The title of the feedback.
     - parameter body:                   The default body text.
     - parameter logs:                   The logs to include in the feedback, if any.
     - parameter logsFileName:           The file name of the logs text file.
     - parameter additionalInformation:  Any additional information you want to capture.
     - parameter applicationInformation: Information about the application to be captured.
     */
    init(screenshot: ScreenshotType,
         screenshotFileName: String = "Screenshot",
         recipients: [String]? = nil,
         title: String? = "Bug Report",
         body: String? = nil,
         logs: [String]? = nil,
         logsFileName: String = "logs",
         additionalInformation: [String: AnyObject]? = nil,
         applicationInformation: ApplicationInformation? = nil) {
        self.screenshot = screenshot
        self.screenshotFileName = screenshotFileName
        self.recipients = recipients
        self.title = title
        self.body = body
        self.logs = logs
        self.logsFileName = logsFileName
        self.additionalInformation = additionalInformation
        self.applicationInformation = applicationInformation
    }
}
