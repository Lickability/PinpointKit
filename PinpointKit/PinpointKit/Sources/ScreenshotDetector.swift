//
//  ScreenshotDetector.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import Photos

/// A class that detects when the user has taken a screenshot and provides it via a delegate callback.

@available(iOS 9.0, *)
public class ScreenshotDetector: NSObject {
    
    /// An error encountered when detecting and retreiving a screenshot.
    enum Error: ErrorType {
        /// The user did not give authorization to this application to their Photo Library.
        case Unauthorized(status: PHAuthorizationStatus)
        
        /// The screenshot metadata could not be fetched from the library.
        case FetchFailure
        
        /// The screenshot image data could not be loaded from the library.
        case LoadFailure
    }
    
    /// A boolean value indicating whether the detector is enabled. When set to true, the detector will request photo access whenever a screenshot is taken by the user and deliver screenshots to its delegate.
    public var detectionEnabled: Bool = true
    
    private weak var delegate: ScreenshotDetectorDelegate?
    private let notificationCenter: NSNotificationCenter
    private let application: UIApplication
    private let imageManager: PHImageManager
    
    /**
     Initializes a `ScreenshotDetector` with its dependencies. Note that `ScreenshotDetector` requires access to the user’s Photo Library and it will request this access if your application does not already have it.
     
     - parameter delegate:           The delegate that will be notified when detection succeeds or fails.
     - parameter notificationCenter: A notification center that will listen for screenshot notifications.
     - parameter application:        An application that will be the `object` of the notification observer.
     - parameter imageManager:       An image manager used to fetch the image data of the screenshot.
     */
    init(delegate: ScreenshotDetectorDelegate, notificationCenter: NSNotificationCenter = .defaultCenter(), application: UIApplication = .sharedApplication(), imageManager: PHImageManager = .defaultManager()) {
        self.delegate = delegate
        self.notificationCenter = notificationCenter
        self.application = application
        self.imageManager = imageManager
        
        super.init()
        
        notificationCenter.addObserver(self, selector: #selector(ScreenshotDetector.userTookScreenshot(_:)), name: UIApplicationUserDidTakeScreenshotNotification, object: application)
    }
    
    @objc private func userTookScreenshot(notification: NSNotification) {
        guard detectionEnabled else { return }
        
        requestPhotosAuthorization()
    }
    
    private func requestPhotosAuthorization() {
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                switch authorizationStatus {
                case .Authorized:
                    self.findScreenshot()
                case .Denied, .NotDetermined, .Restricted:
                    self.fail(.Unauthorized(status: authorizationStatus))
                }
            }
        }
    }
    
    private func findScreenshot() {
        guard let screenshot = PHAsset.fetchLastScreenshot() else { fail(.FetchFailure); return }
        
        imageManager.requestImageForAsset(screenshot,
            targetSize: PHImageManagerMaximumSize,
            contentMode: PHImageContentMode.Default,
            options: PHImageRequestOptions.highQualitySynchronousLocalOptions()) { [weak self] image, info in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                guard let strongSelf = self else { return }
                guard let image = image else { strongSelf.fail(.LoadFailure); return }
                
                strongSelf.succeed(image)
            }
        }
    }
    
    private func succeed(image: UIImage) {
        delegate?.screenshotDetector(self, didDetectScreenshot: image)
    }
    
    private func fail(error: Error) {
        delegate?.screenshotDetector(self, didFailWithError: error)
    }
}

/// A protocol that `ScreenshotDetector` uses to inform its delegate of sucessful and failed screenshot detection events.

@available(iOS 9.0, *)
protocol ScreenshotDetectorDelegate: class {
    
    /**
     Notifies the delegate that the detector did sucessfully detect a screenshot.
     
     - parameter screenshotDetector: The detector responsible for the message.
     - parameter screenshot:         The screeenshot that was detected.
     */
    func screenshotDetector(screenshotDetector: ScreenshotDetector, didDetectScreenshot screenshot: UIImage)
    
    /**
     Notifies the delegate that the detector failed to detect a screenshot.
     
     - parameter screenshotDetector: The detector responsible for the message.
     - parameter error:              The error that occurred while attempting to detecting the screenshot.
     */
    func screenshotDetector(screenshotDetector: ScreenshotDetector, didFailWithError error: ScreenshotDetector.Error)
}

@available(iOS 9.0, *)
private extension PHAsset {

    static func fetchLastScreenshot() -> PHAsset? {
        let options = PHFetchOptions()
        
        options.fetchLimit = 1
        options.includeAssetSourceTypes = [.TypeUserLibrary]
        options.wantsIncrementalChangeDetails = false
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.PhotoScreenshot.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options).firstObject as? PHAsset
    }
}

@available(iOS 9.0, *)
private extension PHImageRequestOptions {
    
    static func highQualitySynchronousLocalOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        options.networkAccessAllowed = false
        options.synchronous = true
        
        return options
    }
}
