//
//  FeedbackCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A protocol describing an object that can collect feedback about a screenshot.
public protocol FeedbackCollector: class, LogSupporting, InterfaceCustomizable {
    
    /// A delegate that is informed of significant events in feedback collection.
    weak var feedbackDelegate: FeedbackCollectorDelegate? { get set }
    
    /// Configuration properties for all feedback to be sent.
    var feedbackConfiguration: FeedbackConfiguration? { get set }
    
    /// The view controller that displays the feedback to collect.
    var viewController: UIViewController { get }
    
    /// The object that is responsible for editing a screenshot.
    var editor: Editor? { get set }
    
    /**
     Begins feedback collection about a screenshot from a view controller.
     
     - parameter screenshot:     The screenshot the user will be providing feedback on.
     - parameter viewController: The view controller from which to present.
     */
    func collectFeedback(with screenshot: UIImage, from viewController: UIViewController)
}

extension FeedbackCollector where Self: UIViewController {
    public var viewController: UIViewController {
        return self
    }
}

/// A delegate protocol that `FeedbackCollector`s use to communicate significant events in feedback collection.
public protocol FeedbackCollectorDelegate: class {
    
    /**
     Informs the receiver that the collector has finished collecting feedback.
     
     - parameter feedbackCollector: The collector which collected the feedback.
     - parameter feedback:          The feedback that was collected by the collector.
     */
    func feedbackCollector(_ feedbackCollector: FeedbackCollector, didCollect feedback: Feedback)
}
