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
        case ImageEncoding
    }
    
    private var mailComposer: MFMailComposeViewController!
    
    // MARK: - Sender
    
    func sendFeedback(feedback: Feedback, fromViewController viewController: UIViewController) {
        mailComposer = MFMailComposeViewController()
        
        if let subject = feedback.title {
            mailComposer.setSubject(subject)
        }
        else {
            //TODO: Default subject
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
        
        // TODO: Encode application information into JSON
        
        // TODO:
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
        //TODO: call the delegate
    }
    
}

private extension MFMailComposeViewController {
    
    func addAttachmentImage(image: UIImage, fileName: String) throws {
        guard let PNGData = UIImagePNGRepresentation(image) else { throw MailSender.Error.ImageEncoding }
        
        addAttachmentData(PNGData, mimeType: MIMEType.PNG.rawValue, fileName: fileName)
    }
}

extension MailSender: MFMailComposeViewControllerDelegate {
    
}
