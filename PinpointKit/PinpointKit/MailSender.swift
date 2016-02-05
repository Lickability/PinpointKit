//
//  MailSender.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import MessageUI

class MailSender: NSObject, Sender {

    enum Error: ErrorType {
        case Unknown
        case NoViewControllerProvided
        case ImageEncoding
        case MailCanceled(underlyingError: NSError?)
        case MailFailed(underlyingError: NSError?)
    }
    
    enum Success: SuccessType {
        case Saved
        case Sent
    }
    
    private var mailComposer: MFMailComposeViewController! {
        didSet {
            mailComposer.mailComposeDelegate = self
        }
    }
    
    private var feedback: Feedback?
    
    // MARK: - Sender
    
    weak var delegate: SenderDelegate?
    
    func sendFeedback(feedback: Feedback, fromViewController viewController: UIViewController?) {
        guard let viewController = viewController else { fail(.NoViewControllerProvided); return }
        
        mailComposer = MFMailComposeViewController()
        self.feedback = feedback
        
        if let subject = feedback.title {
            mailComposer.setSubject(subject)
        }
        
        if let body = feedback.body {
            mailComposer.setMessageBody(body, isHTML: false)
        }

        if let annotatedScreenshot = feedback.annotatedScreenshot {
            attemptToAttachScreeenshot(annotatedScreenshot)
            
        }
        else {
            attemptToAttachScreeenshot(feedback.screenshot)
        }
        
        // TODO: Encode log
        
        if let additionalInformation = feedback.additionalInformation {
            let data = try? NSJSONSerialization.dataWithJSONObject(additionalInformation, options: .PrettyPrinted)
            
            if let data = data {
                mailComposer.addAttachmentData(data, mimeType: MIMEType.JSON.rawValue, fileName: "info.json")
            }
            else {
                print("PinpointKit could not attach Feedback.additionalInformation because it was not valid JSON.")
            }
        }
        
        viewController.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    func attemptToAttachScreeenshot(screenshot: UIImage) {
        do {
            //TODO: Make screenshot.png configurable
            try mailComposer.addAttachmentImage(screenshot, fileName: "Screenshot.png")
        }
        catch (let error as Error) {
            fail(error)
        }
        catch {
            fail(.Unknown)
        }
    }
    
    func fail(error: Error) {
        delegate?.sender(self, didFailToSendFeedback: feedback, error: error)
    }
    
    func succeed(success: Success) {
        delegate?.sender(self, didSendFeedback: feedback, success: success)
    }
    
}

private extension MFMailComposeViewController {
    
    func addAttachmentImage(image: UIImage, fileName: String) throws {
        guard let PNGData = UIImagePNGRepresentation(image) else { throw MailSender.Error.ImageEncoding }
        
        addAttachmentData(PNGData, mimeType: MIMEType.PNG.rawValue, fileName: fileName)
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
