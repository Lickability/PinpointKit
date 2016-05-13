//
//  FeedbackCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A protocol describing an object that can collect feedback about a screenshot.
public protocol FeedbackCollector: FeedbackLogging {
    
    /// A delegate that is informed of significant events in feedback collection.
    var feedbackDelegate: FeedbackCollectorDelegate? { get set }
    
    /// The configuration that the collector should use to set itself up.
    var interfaceCustomization: InterfaceCustomization? { get set }
    
    /**
     Begins feedback collection about a screenshot from a view controller.
     
     - parameter screenshot:     The screenshot the user will be providing feedback on.
     - parameter viewController: The view controller from which to present.
     */
    func collectFeedbackWithScreenshot(screenshot: UIImage, fromViewController viewController: UIViewController)
}

/// A delegate protocol that `FeedbackCollector`s use to communicate significant events in feedback collection.
public protocol FeedbackCollectorDelegate: class {
    
    /**
     Informs the receiver that the collector has finished collecting feedback.
     
     - parameter feedbackCollector: The collector which collected the feedback.
     - parameter feedback:          The feedback that was collected by the collector.
     */
    func feedbackCollector(feedbackCollector: FeedbackCollector, didCollectFeedback feedback: Feedback)
}
