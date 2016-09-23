//
//  Sender.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A behavior protocol that describes an object that sends feedback.
public protocol Sender: class {
    
    /// A delegate that is informed of successful or failed feedback sending.
    weak var delegate: SenderDelegate? { get set }
    
    /**
     Sends the feedback using the provided view controller as a presenting view controller.
     
     - parameter feedback:       The feedback to send.
     - parameter viewController: The view controller from which to present any of the sender’s necessary views.
     */
    func send(_ feedback: Feedback, from viewController: UIViewController?)
}

/// A delegate protocol describing an object that receives success and failure events from a `Sender`.
public protocol SenderDelegate: class {    
    
    /**
     Notifies the receiver that the sender successfully sent the feedback with a given type of success.
     
     - parameter sender:   The object responsible for the successful sending.
     - parameter feedback: The feedback that was sent.
     - parameter success:  The optional type of success.
     */
    func sender(_ sender: Sender, didSend feedback: Feedback?, success: SuccessType?)
    
    /**
     Notifies the receiver that the sender failed to send the feedback with a given error.
     
     - parameter sender:   The object responsible for the failed sending.
     - parameter feedback: The feedback that failed to send.
     - parameter error:    The error that caused the failure.
     */
    func sender(_ sender: Sender, didFailToSend feedback: Feedback?, error: Error)
}

/// An extension on PinpointKitDelegate that makes some of the delegate methods optional by giving them empty implementations by default.
public extension SenderDelegate {

    func sender(_ sender: Sender, didFailToSend feedback: Feedback?, error: Error) { }
}
