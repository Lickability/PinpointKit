//
//  Sender.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

protocol Sender {
    var delegate: SenderDelegate? { get set }
    
    func sendFeedback(feedback: Feedback, fromViewController viewController: UIViewController)
}

protocol SenderDelegate: class {
    func sender(sender: Sender, didSendFeedback feedback: Feedback?, success: SuccessType?)
    func sender(sender: Sender, didFailToSendFeedback feedback: Feedback?, error: ErrorType)
}
