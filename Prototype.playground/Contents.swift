//: Playground - noun: a place where people can play

import UIKit

class PinpointKit {
    
    struct Configuration {
        static let defaultConfiguration = Configuration()

        var fillColor: UIColor = .redColor()
        var strokeColor: UIColor = .whiteColor()
        
        var screenshotEditor: ScreenshotEditor = EditImageViewController()
        var feedbackCollector: FeedbackCollector = FeedbackViewController()
        var sender: Sender = MailSender()
    }
    
    static let defaultPinpointKit = PinpointKit()
    
    let configuration: Configuration
    weak var delegate: PinpointKitDelegate?
    
    init(configuration: Configuration = Configuration.defaultConfiguration, delegate: PinpointKitDelegate? = nil)  {
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

protocol Sender {}

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

class MailSender: NSObject, Sender {}

