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
open class ScreenshotDetector: NSObject {
    
    /// An error encountered when detecting and retreiving a screenshot.
    public enum Error: Swift.Error {
        /// The user did not give authorization to this application to their Photo Library.
        case unauthorized(status: PHAuthorizationStatus)
        
        /// The screenshot metadata could not be fetched from the library.
        case fetchFailure
        
        /// The screenshot image data could not be loaded from the library.
        case loadFailure
    }
    
    /// A boolean value indicating whether the detector is enabled. When set to true, the detector will request photo access whenever a screenshot is taken by the user and deliver screenshots to its delegate.
    open var detectionEnabled: Bool = true
    
    private weak var delegate: ScreenshotDetectorDelegate?
    private let notificationCenter: NotificationCenter
    private let application: UIApplication
    private let imageManager: PHImageManager?
    fileprivate let photoLibrary: PHPhotoLibrary
    
    /**
     Initializes a `ScreenshotDetector` with its dependencies. Note that `ScreenshotDetector` requires access to the user’s Photo Library and it will request this access if your application does not already have it.
     
     - parameter delegate:           The delegate that will be notified when detection succeeds or fails.
     - parameter notificationCenter: A notification center that will listen for screenshot notifications.
     - parameter application:        An application that will be the `object` of the notification observer.
     - parameter imageManager:       An image manager used to fetch the image data of the screenshot. If `nil`, the `default()` image manager will be used.
     - parameter photoLibrary:       The photo library used for detecting a change event after a screenshot is taken. Defaults to `.shared()`.
     */
    public init(delegate: ScreenshotDetectorDelegate, notificationCenter: NotificationCenter = .default, application: UIApplication = .shared, imageManager: PHImageManager? = nil, photoLibrary: PHPhotoLibrary = .shared()) {
        self.delegate = delegate
        self.notificationCenter = notificationCenter
        self.application = application
        self.imageManager = imageManager
        self.photoLibrary = photoLibrary
        
        super.init()
        
        notificationCenter.addObserver(self, selector: #selector(ScreenshotDetector.userTookScreenshot(_:)), name: UIApplication.userDidTakeScreenshotNotification, object: application)
    }
    
    @objc private func userTookScreenshot(_ notification: Notification) {
        guard detectionEnabled else { return }
        
        requestPhotosAuthorization()
    }
    
    private func requestPhotosAuthorization() {
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            OperationQueue.main.addOperation {
                switch authorizationStatus {
                case .authorized:
                    // Register for the next photo library change notification since the new screenshot
                    // won’t be available immediately.
                    self.photoLibrary.register(self)
                case .denied, .notDetermined, .restricted:
                    self.fail(with: .unauthorized(status: authorizationStatus))
                }
            }
        }
    }
    
    fileprivate func findScreenshot() {
        guard let screenshot = PHAsset.fetchLastScreenshot() else { fail(with: .fetchFailure); return }
        
        // Fall back to the `.default()` image manager if an image manager wasn’t set on initialization.
        // We don’t specify this as a default parameter to the initializer since calling `.default()`
        // immediately prompts the user for access to the photo library, before we even need to use it.
        let imageManager: PHImageManager = self.imageManager ?? .default()
        
        imageManager.requestImage(for: screenshot,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .default,
            options: PHImageRequestOptions.highQualitySynchronousLocalOptions()) { [weak self] image, _ in
            OperationQueue.main.addOperation {
                guard let strongSelf = self else { return }
                guard let image = image else { strongSelf.fail(with: .loadFailure); return }
                
                strongSelf.succeed(with: image)
            }
        }
    }
    
    private func succeed(with image: UIImage) {
        delegate?.screenshotDetector(self, didDetect: image)
    }
    
    private func fail(with error: Error) {
        delegate?.screenshotDetector(self, didFailWith: error)
    }
}

/// A protocol that `ScreenshotDetector` uses to inform its delegate of successful and failed screenshot detection events.

@available(iOS 9.0, *)
public protocol ScreenshotDetectorDelegate: class {
    
    /**
     Notifies the delegate that the detector did successfully detect a screenshot.
     
     - parameter screenshotDetector: The detector responsible for the message.
     - parameter screenshot:         The screenshot that was detected.
     */
    func screenshotDetector(_ screenshotDetector: ScreenshotDetector, didDetect screenshot: UIImage)
    
    /**
     Notifies the delegate that the detector failed to detect a screenshot.
     
     - parameter screenshotDetector: The detector responsible for the message.
     - parameter error:              The error that occurred while attempting to detect the screenshot.
     */
    func screenshotDetector(_ screenshotDetector: ScreenshotDetector, didFailWith error: ScreenshotDetector.Error)
}

@available(iOS 9.0, *)
private extension PHAsset {
    
    static func fetchLastScreenshot() -> PHAsset? {
        let options = PHFetchOptions()
        
        options.fetchLimit = 1
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.wantsIncrementalChangeDetails = false
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return PHAsset.fetchAssets(with: .image, options: options).firstObject
    }
}

@available(iOS 9.0, *)
private extension PHImageRequestOptions {
    
    static func highQualitySynchronousLocalOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        options.isSynchronous = true
        
        return options
    }
}

extension ScreenshotDetector: PHPhotoLibraryChangeObserver {
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        photoLibrary.unregisterChangeObserver(self)
        findScreenshot()
    }
}
