//
//  MailSender.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import MessageUI

/// A `Sender` that uses `MessageUI` to send an email containing the feedback.
open class MailSender: NSObject, Sender {

    /// An error in sending feedback.
    enum Error: Swift.Error {

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
        case mailCanceled(underlyingError: Swift.Error?)
        
        /// Email sending failed.
        case mailFailed(underlyingError: Swift.Error?)
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
    weak open var delegate: SenderDelegate?
    
    /**
     Sends the feedback using the provided view controller as a presenting view controller.
     
     - parameter feedback:       The feedback to send.
     - parameter viewController: The view controller from which to present any of the sender’s necessary views.
     */
    open func send(_ feedback: Feedback, from viewController: UIViewController?) {
        guard let viewController = viewController else { fail(with: .noViewControllerProvided); return }
        
        guard MFMailComposeViewController.canSendMail() else { fail(with: .mailCannotSend); return }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        self.feedback = feedback
        
        do {
            try mailComposer.attach(feedback)
        } catch let error as Error {
            fail(with: error)
        } catch {
            fail(with: .unknown)
        }
        
        viewController.present(mailComposer, animated: true, completion: nil)
    }
    
    // MARK: - MailSender
    
    fileprivate func fail(with error: Error) {
        delegate?.sender(self, didFailToSend: feedback, error: error)
        feedback = nil
    }
    
    fileprivate func succeed(with success: Success) {
        delegate?.sender(self, didSend: feedback, success: success)
        feedback = nil
    }
}

private extension MFMailComposeViewController {
    
    func attach(_ feedback: Feedback) throws {
        setToRecipients(feedback.configuration.recipients)
        
        if let subject = feedback.configuration.title {
            setSubject(subject)
        }
        
        if let body = feedback.configuration.body {
           setMessageBody(body, isHTML: false)
        }
        
        try attach(feedback.screenshot, screenshotFileName: feedback.configuration.screenshotFileName)
        
        if let logs = feedback.logs {
            try attach(logs, logsFileName: feedback.configuration.logsFileName)
        }
        
        if let additionalInformation = feedback.configuration.additionalInformation {
            attach(additionalInformation)
        }
    }
    
    func attach(_ screenshot: Feedback.ScreenshotType, screenshotFileName: String) throws {
        try attach(screenshot.preferredImage, filename: screenshotFileName + MIMEType.PNG.fileExtension)
    }
    
    func attach(_ logs: [String], logsFileName: String) throws {
        let logsText = logs.joined(separator: "\n\n")
        try attach(logsText, filename: logsFileName + MIMEType.PlainText.fileExtension)
    }
    
    func attach(_ image: UIImage, filename: String) throws {
        guard let PNGData = UIImagePNGRepresentation(image) else { throw MailSender.Error.imageEncoding }
        
        addAttachmentData(PNGData, mimeType: MIMEType.PNG.rawValue, fileName: filename)
    }
    
    func attach(_ text: String, filename: String) throws {
        guard let textData = text.data(using: String.Encoding.utf8) else { throw MailSender.Error.textEncoding }
        
        addAttachmentData(textData, mimeType: MIMEType.PlainText.rawValue, fileName: filename)
    }
    
    func attach(_ additionalInformation: [String: AnyObject]) {
        let data = try? JSONSerialization.data(withJSONObject: additionalInformation, options: .prettyPrinted)
        
        if let data = data {
            addAttachmentData(data, mimeType: MIMEType.JSON.rawValue, fileName: "info.json")
        } else {
            NSLog("PinpointKit could not attach Feedback.additionalInformation because it was not valid JSON.")
        }
    }
}

extension MailSender: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        controller.dismiss(animated: true) {
            self.completeWithResult(result, error: error)
        }
    }
    
    private func completeWithResult(_ result: MFMailComposeResult, error: Swift.Error?) {
        switch result {
        case .cancelled:
            fail(with: .mailCanceled(underlyingError: error))
        case .failed:
            fail(with: .mailFailed(underlyingError: error))
        case .saved:
            succeed(with: .saved)
        case .sent:
            succeed(with: .sent)
        }
    }
}
