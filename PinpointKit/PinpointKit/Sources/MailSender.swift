//
//  MailSender.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import MessageUI

/// A `Sender` that uses `MessageUI` to send an email containing the feedback.
public class MailSender: NSObject, Sender {

    /// An error in sending feedback.
    enum Error: ErrorProtocol {

        /// An unknown error occured.
        case unknown

        /// No view controller was provided for presentation.
        case noViewControllerProvided
        
        /// The screenshot failed to encode.
        case imageEncoding
        
        /// The text failed to encode.
        case textEncoding
        
        /// `MFMailComposeViewController.canSendMail()` returned `false`.
        case mailCannotSend
        
        /// Email composing was canceled by the user.
        case mailCanceled(underlyingError: NSError?)
        
        /// Email sending failed.
        case mailFailed(underlyingError: NSError?)
    }
    
    /// A success in sending feedback.
    enum Success: SuccessType {
        
        /// The email was saved as a draft.
        case saved
        
        /// The email was sent.
        case sent
    }
    
    private var feedback: Feedback?
    
    // MARK: - Sender
    
    /// A delegate that is informed of successful or failed feedback sending.
    weak public var delegate: SenderDelegate?
    
    /**
     Sends the feedback using the provided view controller as a presenting view controller.
     
     - parameter feedback:       The feedback to send.
     - parameter viewController: The view controller from which to present any of the sender’s necessary views.
     */
    public func sendFeedback(_ feedback: Feedback, fromViewController viewController: UIViewController?) {
        guard let viewController = viewController else { fail(.noViewControllerProvided); return }
        
        guard MFMailComposeViewController.canSendMail() else { fail(.mailCannotSend); return }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        self.feedback = feedback
        
        do {
            try mailComposer.attach(feedback)
        } catch let error as Error {
            fail(error)
        } catch {
            fail(.unknown)
        }
        
        viewController.present(mailComposer, animated: true, completion: nil)
    }
    
    // MARK: - MailSender
    
    private func fail(_ error: Error) {
        delegate?.sender(self, didFailToSendFeedback: feedback, error: error)
        feedback = nil
    }
    
    private func succeed(_ success: Success) {
        delegate?.sender(self, didSendFeedback: feedback, success: success)
        feedback = nil
    }
}

private extension MFMailComposeViewController {
    
    func attach(_ feedback: Feedback) throws {
        setToRecipients(feedback.recipients)
        
        if let subject = feedback.title {
            setSubject(subject)
        }
        
        if let body = feedback.body {
           setMessageBody(body, isHTML: false)
        }
        
        try attach(feedback.screenshot, screenshotFileName: feedback.screenshotFileName)
        
        if let logs = feedback.logs {
            try attach(logs, logsFileName: feedback.logsFileName)
        }
        
        if let additionalInformation = feedback.additionalInformation {
            attachAdditionalInformation(additionalInformation)
        }
    }
    
    func attach(_ screenshot: Feedback.ScreenshotType, screenshotFileName: String) throws {
        try attachImage(screenshot.preferredImage, filename: screenshotFileName + MIMEType.PNG.fileExtension)
    }
    
    func attach(_ logs: [String], logsFileName: String) throws {
        let logsText = logs.joined(separator: "\n\n")
        try attachText(logsText, filename: logsFileName + MIMEType.PlainText.fileExtension)
    }
    
    func attachImage(_ image: UIImage, filename: String) throws {
        guard let PNGData = UIImagePNGRepresentation(image) else { throw MailSender.Error.imageEncoding }
        
        addAttachmentData(PNGData, mimeType: MIMEType.PNG.rawValue, fileName: filename)
    }
    
    func attachText(_ text: String, filename: String) throws {
        guard let textData = text.data(using: String.Encoding.utf8) else { throw MailSender.Error.textEncoding }
        
        addAttachmentData(textData, mimeType: MIMEType.PlainText.rawValue, fileName: filename)
    }
    
    func attachAdditionalInformation(_ additionalInformation: [String: AnyObject]) {
        let data = try? JSONSerialization.data(withJSONObject: additionalInformation, options: .prettyPrinted)
        
        if let data = data {
            addAttachmentData(data, mimeType: MIMEType.JSON.rawValue, fileName: "info.json")
        } else {
            NSLog("PinpointKit could not attach Feedback.additionalInformation because it was not valid JSON.")
        }
    }
}

extension MailSender: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true) {
            self.completeWithResult(result, error: error)
        }
    }
    
    private func completeWithResult(_ result: MFMailComposeResult, error: NSError?) {
        switch result {
        case .cancelled:
            fail(.mailCanceled(underlyingError: error))
        case .failed:
            fail(.mailFailed(underlyingError: error))
        case .saved:
            succeed(.saved)
        case .sent:
            succeed(.sent)
        }
    }
}
