//
//  MailSender.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import MessageUI

/// A `Sender` that uses `MessageUI` to send an email containing the feedback.
class MailSender: NSObject, Sender {

    /// An error in sending feedback.
    enum Error: ErrorType {

        /// An unknown error occured.
        case Unknown

        /// No view controller was provided for presentation.
        case NoViewControllerProvided
        
        /// The screenshot failed to encode.
        case ImageEncoding
        
        /// `MFMailComposeViewController.canSendMail()` returned `false`.
        case MailCannotSend
        
        /// Email composing was canceled by the user.
        case MailCanceled(underlyingError: NSError?)
        
        /// Email sending failed.
        case MailFailed(underlyingError: NSError?)
    }
    
    /// A success in sending feedback.
    enum Success: SuccessType {
        
        /// The email was saved as a draft.
        case Saved
        
        /// The email was sent.
        case Sent
    }
    
    private var feedback: Feedback?
    
    // MARK: - Sender
    
    /// A delegate that is informed of successful or failed feedback sending.
    weak var delegate: SenderDelegate?
    
    /**
     Sends the feedback using the provided view controller as a presenting view controller.
     
     - parameter feedback:       The feedback to send.
     - parameter viewController: The view controller from which to present any of the sender’s necessary views.
     */
    func sendFeedback(feedback: Feedback, fromViewController viewController: UIViewController?) {
        guard let viewController = viewController else { fail(.NoViewControllerProvided); return }
        
        guard MFMailComposeViewController.canSendMail() else { fail(.MailCannotSend); return }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        self.feedback = feedback
        
        tryToAttachFeedback(feedback, toMailComposer: mailComposer)
        
        viewController.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    private func tryToAttachFeedback(feedback: Feedback, toMailComposer mailComposer: MFMailComposeViewController) {
        do {
            try mailComposer.attachFeedback(feedback)
        }
        catch let error as Error {
            fail(error)
        }
        catch {
            fail(.Unknown)
        }
    }
    
    // MARK: - MailSender
    
    private func fail(error: Error) {
        delegate?.sender(self, didFailToSendFeedback: feedback, error: error)
    }
    
    private func succeed(success: Success) {
        delegate?.sender(self, didSendFeedback: feedback, success: success)
    }
}

private extension MFMailComposeViewController {
    
    func attachFeedback(feedback: Feedback) throws {
        if let subject = feedback.title {
            setSubject(subject)
        }
        
        if let body = feedback.body {
           setMessageBody(body, isHTML: false)
        }
        
        try attachScreeenshot(feedback.annotatedScreenshot ?? feedback.screenshot, screenshotFilename: feedback.screenshotFilename)
        
        // TODO: Encode log once it exists.
        
        if let additionalInformation = feedback.additionalInformation {
            attachAdditionalInformation(additionalInformation)
        }
    }
    
    func attachScreeenshot(screenshot: UIImage, screenshotFilename: String?) throws {
        let fileName = screenshotFilename ?? NSLocalizedString("Screenshot", comment: "The name of a screenshot file")
        try attachImage(screenshot, filename: fileName + ".png")
    }
    
    func attachImage(image: UIImage, filename: String) throws {
        guard let PNGData = UIImagePNGRepresentation(image) else { throw MailSender.Error.ImageEncoding }
        
        addAttachmentData(PNGData, mimeType: MIMEType.PNG.rawValue, fileName: filename)
    }
    
    func attachAdditionalInformation(additionalInformation: [String: AnyObject]) {
        let data = try? NSJSONSerialization.dataWithJSONObject(additionalInformation, options: .PrettyPrinted)
        
        if let data = data {
            addAttachmentData(data, mimeType: MIMEType.JSON.rawValue, fileName: "info.json")
        }
        else {
            print("PinpointKit could not attach Feedback.additionalInformation because it was not valid JSON.")
        }
    }
    
}

extension MailSender: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true) {
            self.completeWithResult(result, error: error)
        }
    }
    
    private func completeWithResult(result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            fail(.MailCanceled(underlyingError: error))
        case MFMailComposeResultFailed:
            fail(.MailFailed(underlyingError: error))
        case MFMailComposeResultSaved:
            succeed(.Saved)
        case MFMailComposeResultSent:
            succeed(.Sent)
        default:
            fail(.Unknown)
        }
    }
}
