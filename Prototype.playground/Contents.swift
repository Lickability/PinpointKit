//: Playground - noun: a place where people can play

import UIKit
import MessageUI

class PinpointKit {
    struct Configuration {
        let tintColor: UIColor
        let annotationStrokeColor: UIColor
        
        let screenshotEditor: ScreenshotEditor
        let feedbackCollector: FeedbackCollector
        let sender: Sender
        let logCollector: LogCollector?
        
        init(tintColor: UIColor = .redColor(), annotationStrokeColor: UIColor = .whiteColor(), screenshotEditor: ScreenshotEditor = EditImageViewController(), feedbackCollector: FeedbackCollector = FeedbackViewController(), sender: Sender = MailSender(), logCollector: LogCollector? = SystemLogCollector()) {
            self.tintColor = tintColor
            self.annotationStrokeColor = annotationStrokeColor
            self.screenshotEditor = screenshotEditor
            self.feedbackCollector = feedbackCollector
            self.sender = sender
            self.logCollector = logCollector
        }
    }
    
    static let defaultPinpointKit = PinpointKit()
    
    let configuration: Configuration
    weak var delegate: PinpointKitDelegate?
    
    init(configuration: Configuration = Configuration(), delegate: PinpointKitDelegate? = nil)  {
        self.configuration = configuration
        self.delegate = delegate
    }
    
    func showFromViewController(viewController: UIViewController) {}
}

protocol PinpointKitDelegate: class {
    func pinpointKit(pinpointKit: PinpointKit, willShowFeedbackCollector: FeedbackCollector)
    func pinpointKit(pinpointKit: PinpointKit, didShowFeedbackCollector: FeedbackCollector)
    
    func pinpointKit(pinpointKit: PinpointKit, willSendFeedback: Feedback)
    func pinpointKit(pinpointKit: PinpointKit, didSendFeedback: Feedback)
    
    func pinpointKit(pinpointKit: PinpointKit, willShowScreenshotEditor: ScreenshotEditor)
    func pinpointKit(pinpointKit: PinpointKit, didShowScreenshotEditor: ScreenshotEditor)
    
    func pinpointKit(pinpointKit: PinpointKit, didFinishWithFeedback: Feedback?)
    func pinpointKit(pinpointKit: PinpointKit, didFailWithError: ErrorType)
}

// Default protocol extension to make all functions in the delegate optional.
extension PinpointKitDelegate {
    func pinpointKit(pinpointKit: PinpointKit, willShowFeedbackCollector: FeedbackCollector) {}
    func pinpointKit(pinpointKit: PinpointKit, didShowFeedbackCollector: FeedbackCollector) {}
    
    func pinpointKit(pinpointKit: PinpointKit, willSendFeedback: Feedback) {}
    func pinpointKit(pinpointKit: PinpointKit, didSendFeedback: Feedback) {}
    
    func pinpointKit(pinpointKit: PinpointKit, willShowScreenshotEditor: ScreenshotEditor) {}
    func pinpointKit(pinpointKit: PinpointKit, didShowScreenshotEditor: ScreenshotEditor) {}

    func pinpointKit(pinpointKit: PinpointKit, didFinishWithFeedback: Feedback?) {}
    func pinpointKit(pinpointKit: PinpointKit, didFailWithError: ErrorType) {}
}

enum PinpointError: ErrorType {
    case UnknownError
}

protocol Sender {}

protocol LogCollector {}

enum LogCollectorBehavior {
    case CollectSilently
    case CollectAndPrompt(promptText: String)
}

struct Feedback {
    let image: UIImage
    let title: String
    let body: String
    
    let appVersion: String
    let appName: String
    
    let additionalInformation: [String: AnyObject]
}

protocol FeedbackCollector {}

protocol ScreenshotEditor {}

protocol GestureWindowDelegate: class {}

class GestureWindow: UIWindow {
    weak var delegate: GestureWindowDelegate?
}

class EditImageViewController: UIViewController, ScreenshotEditor {}

class FeedbackViewController: UIViewController, FeedbackCollector {}

class MailSender: NSObject, MFMailComposeViewControllerDelegate, Sender {}

class SystemLogCollector: LogCollector {}

