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
        case original(image: UIImage)
        
        /// An annotated screenshot.
        case annotated(image: UIImage)
        
        /// Both the original and annotated screenshot.
        case combined(originalImage: UIImage, annotatedImage: UIImage)
        
        /// Returns an image of the screenshot preferring the annotated image.
        public var preferredImage: UIImage {
            switch self {
            case let .original(image):
                return image
            case let .annotated(image):
                return image
            case let .combined(_, annotatedImage):
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
        
        /// The application’s bundle identifier.
        public let bundleIdentifier: String?
        
        /// The operating system version of the OS in which the application is running.
        public let operatingSystemVersion: OperatingSystemVersion?
        
        /**
         Initializes a new `ApplicationInformation`.
         
         - parameter version:                The application’s marketing version.
         - parameter build:                  The application’s build number.
         - parameter name:                   The application’s display name.
         - parameter bundleIdentifier:       The application’s bundle identifier.
         - parameter operatingSystemVersion: The operating system version of the OS in which the application is running.
         */
        public init(version: String?, build: String?, name: String?, bundleIdentifier: String?, operatingSystemVersion: OperatingSystemVersion?) {
            self.version = version
            self.build = build
            self.name = name
            self.bundleIdentifier = bundleIdentifier
            self.operatingSystemVersion = operatingSystemVersion
        }
    }
    
    /// A screenshot of the screen the feedback relates to.
    public let screenshot: ScreenshotType
    
    /// An optional collection of log strings.
    public let logs: [String]?
    
    /// A struct containing information about the application and its environment.
    public let applicationInformation: ApplicationInformation?
    
    /// Specifies configurable properties for feedback.
    public var configuration: FeedbackConfiguration
    
    /**
     Initializes a `Feedback` with optional default values.
     
     - parameter screenshot:             The type of screenshot in the feedback.
     - parameter logs:                   The logs to include in the feedback, if any.
     - parameter applicationInformation: Information about the application to be captured.
     - parameter configuration:          Configurable properties for feedback.
     */
    public init(screenshot: ScreenshotType,
                logs: [String]? = nil,
                applicationInformation: ApplicationInformation? = nil,
                configuration: FeedbackConfiguration) {
        self.screenshot = screenshot
        self.logs = logs
        self.applicationInformation = applicationInformation
        self.configuration = configuration
    }
}
