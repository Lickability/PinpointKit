//
//  PinpointKit.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 1/22/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation


/// `PinpointKit` is an object that can be used to collect feedback from application users.
public class PinpointKit {

    /// Returns a `PinpointKit` instance with a default configuration.
    public static let defaultPinpointKit = PinpointKit()

    /// The configuration struct that specifies how PinpointKit should be configured.
    private let configuration: Configuration
    
    /// A delegate that is notified of significant events.
    private weak var delegate: PinpointKitDelegate?
    
    private weak var displayingViewController: UIViewController?
    
    /**
     Initializes a `PinpointKit` object with a configuration and an optional delegate.
     
     - parameter configuration: The configuration struct that specifies how PinpointKit should be configured.
     - parameter delegate:      A delegate that is notified of significant events.
     */
    public init(configuration: Configuration = Configuration(), delegate: PinpointKitDelegate? = nil) {
        self.configuration = configuration
        self.delegate = delegate
        
        self.configuration.feedbackCollector.feedbackDelegate = self
        self.configuration.sender.delegate = self
    }
    
    /**
     Shows PinpointKit’s feedback collection UI from a given view controller.
     
     - parameter viewController: The view controller from which to present.
     */
    public func show(fromViewController viewController: UIViewController) {
        let screenshot = Screenshotter.takeScreenshot()
        displayingViewController = viewController
        
        configuration.feedbackCollector.collectFeedback(with: screenshot, from: viewController)
    }
}

// MARK: - FeedbackCollectorDelegate

extension PinpointKit: FeedbackCollectorDelegate {
    
    public func feedbackCollector(_ feedbackCollector: FeedbackCollector, didCollect feedback: Feedback) {
        delegate?.pinpointKit(self, willSend: feedback)
        configuration.sender.sendFeedback(feedback, fromViewController: feedbackCollector.viewController)
    }
}

// MARK: - SenderDelegate

extension PinpointKit: SenderDelegate {
    
    public func sender(_ sender: Sender, didSend feedback: Feedback?, success: SuccessType?) {
        guard let feedback = feedback else { return }
        
        delegate?.pinpointKit(self, didSend: feedback)
        displayingViewController?.dismiss(animated: true, completion: nil)
    }
    
    public func sender(_ sender: Sender, didFailToSend feedback: Feedback?, error: ErrorProtocol) {
        if case MailSender.Error.mailCanceled = error { return }
        
        NSLog("An error occurred sending mail: \(error)")
    }
}

/// A protocol describing an object that can be notified of events from PinpointKit.
public protocol PinpointKitDelegate: class {

    /**
     Notifies the delegate that PinpointKit is about to send user feedback.
     
     - parameter pinpointKit:   The `PinpointKit` instance responsible for the feedback.
     - parameter feedback:      The feedback that’s about to be sent.
     */
    func pinpointKit(_ pinpointKit: PinpointKit, willSend feedback: Feedback)
    
    /**
     Notifies the delegate that PinpointKit has just sent user feedback.
     
     - parameter pinpointKit:   The `PinpointKit` instance responsible for the feedback.
     - parameter feedback:      The feedback that’s just been sent.
     */
    func pinpointKit(_ pinpointKit: PinpointKit, didSend feedback: Feedback)
}

/// An extension on PinpointKitDelegate that makes all delegate methods optional by giving them empty implementations by default.
public extension PinpointKitDelegate {
    
    func pinpointKit(_ pinpointKit: PinpointKit, willSend feedback: Feedback) {}
    func pinpointKit(_ pinpointKit: PinpointKit, didSend feedback: Feedback) {}
}
