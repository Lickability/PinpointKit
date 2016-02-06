//
//  Feedback.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/**
 *  A struct containing user feedback on an application.
 */
public struct Feedback {
    
    /// An un-annotated screenshot of the screen the feedback relates to.
    let screenshot: UIImage
    
    /// An annotated screenshot of the screen the feedback relates to or `nil` if the user did not annotate it.
    let annotatedScreenshot: UIImage?
    
    /// A filename without an extension for the screenshot or annotated screenshot.
    let screenshotFilename: String
    
    /// A short, optional title of the feedback submission. Suitable for an email subject.
    let title: String?
    
    /// An optional plain-text body of the feedback submission. Suitable for an email body.
    let body: String?
    
    /// A dictionary of additional information provided by the application developer.
    let additionalInformation: [String: AnyObject]?
    
    /// A struct containing information about the application and its environment.
    let applicationInformation: ApplicationInformation?
    
    /**
     *  A substructure containing information about the application and its environment.
     */
    struct ApplicationInformation {
        /// The application’s marketing version.
        let version: String?
        
        /// The application’s build number.
        let build: String?
        
        /// The application’s display name.
        let name: String?
        
        /// The application’s bundle identifer.
        let bundleIdentifer: String?
        
        /// The operating system version of the OS in which the application is running.
        let operatingSystemVersion: NSOperatingSystemVersion?
    }

}
