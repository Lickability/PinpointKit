//: Playground - noun: a place where people can play

import UIKit

class PinpointKit {
    
    struct Configuration {
        
        enum LogCollectionStatus {
            case CollectSilently(collector: LogCollector)
            case CollectAndPrompt(collector: LogCollector, promptText: String)
            case DoNotCollect
        }
        
        let tintColor: UIColor
        let annotationStrokeColor: UIColor
        
        let logCollectionStatus: LogCollectionStatus
        
        let screenshotEditor: ScreenshotEditor
        let feedbackCollector: FeedbackCollector?
        let sender: Sender
        
        init(tintColor: UIColor = .redColor(), annotationStrokeColor: UIColor = .whiteColor(), logCollectionStatus: LogCollectionStatus = LogCollectionStatus.CollectAndPrompt(collector: SystemLogCollector(), promptText: NSLocalizedString("Include Console Log", comment: "Text asking whether or not to include a console log in a feedback form.")), screenshotEditor: ScreenshotEditor = EditImageViewController(), feedbackCollector: FeedbackCollector? = FeedbackViewController(), sender: Sender = MailSender()) {
            self.tintColor = tintColor
            self.annotationStrokeColor = annotationStrokeColor
            self.logCollectionStatus = logCollectionStatus
            self.screenshotEditor = screenshotEditor
            self.feedbackCollector = feedbackCollector
            self.sender = sender
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
    
    func pinpointKit(pinpointKit: PinpointKit, didFinishWithResult: Bool)
}

// Default protocol extension to make all functions in the delegate optional.
extension PinpointKitDelegate {
    func pinpointKit(pinpointKit: PinpointKit, willShowFeedbackCollector: FeedbackCollector) {}
    func pinpointKit(pinpointKit: PinpointKit, didShowFeedbackCollector: FeedbackCollector) {}
    
    func pinpointKit(pinpointKit: PinpointKit, willSendFeedback: Feedback) {}
    func pinpointKit(pinpointKit: PinpointKit, didSendFeedback: Feedback) {}
    
    func pinpointKit(pinpointKit: PinpointKit, willShowScreenshotEditor: ScreenshotEditor) {}
    func pinpointKit(pinpointKit: PinpointKit, didShowScreenshotEditor: ScreenshotEditor) {}
    
    func pinpointKit(pinpointKit: PinpointKit, didFinishWithResult: Bool) {}
}

protocol Sender {}

protocol LogCollector {}

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

class MailSender: Sender {}

class SystemLogCollector: LogCollector {}


