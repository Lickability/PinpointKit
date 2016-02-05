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
final class ScreenshotDetector: NSObject {
    private weak var delegate: ScreenshotDetectorDelegate?
    private let notificationCenter: NSNotificationCenter
    private let application: UIApplication
    private let imageManager: PHImageManager
    
    /// An error encountered when detecting and retreiving a screenshot.
    enum Error: ErrorType {
        /// The user did not give authorization to this application to their Photo Library.
        case Unauthorized(status: PHAuthorizationStatus)
        
        /// The screenshot metadata could not be fetched from the library.
        case FetchFailure
        
        /// The screenshot image data could not be loaded from the library.
        case LoadFailure
    }

    init(delegate: ScreenshotDetectorDelegate, notificationCenter: NSNotificationCenter = .defaultCenter(), application: UIApplication = .sharedApplication(), imageManager: PHImageManager = .defaultManager()) {
        self.delegate = delegate
        self.notificationCenter = notificationCenter
        self.application = application
        self.imageManager = imageManager
        
        super.init()
        
        notificationCenter.addObserver(self, selector: "userTookScreenshot:", name: UIApplicationUserDidTakeScreenshotNotification, object: application)
    }
    
    private func userTookScreenshot(notification: NSNotification) {
        
        requestPhotosAuthorization()
        
        //TODO: Open PinpointKit.
    }
    
    private func requestPhotosAuthorization() {
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .Authorized:
                self.findScreenshot()
            case .Denied, .NotDetermined, .Restricted:
                self.fail(.Unauthorized(status: authorizationStatus))
            }
        }
    }
    
    private func findScreenshot() {
        guard let screenshot = PHFetchResult.lastScreenshotFetchResult().firstObject as? PHAsset else {
            fail(.FetchFailure)
            return }

        imageManager.requestImageForAsset(screenshot, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.Default, options: nil) { image, info in
            guard let image = image else {
                self.fail(.LoadFailure)
                return
            }
            
                self.succeed(image)
        }
    }
    
    private func succeed(image: UIImage) {
        self.delegate?.screenshotDetector(self, didDetectScreenshot: image)
    }
    
    private func fail(error: Error) {
        self.delegate?.screenshotDetector(self, didFailWithError: error)
    }
}

protocol ScreenshotDetectorDelegate: class {
    func screenshotDetector(screenshotDetector: ScreenshotDetector, didDetectScreenshot screenshot: UIImage)
    func screenshotDetector(screenshotDetector: ScreenshotDetector, didFailWithError error: ScreenshotDetector.Error)
}

private extension PHFetchResult {
    static func lastScreenshotFetchResult() -> PHFetchResult {
        let options = PHFetchOptions()
        
        options.fetchLimit = 1
        options.includeAssetSourceTypes = [.TypeUserLibrary]
        options.wantsIncrementalChangeDetails = false
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.PhotoScreenshot.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }
}
