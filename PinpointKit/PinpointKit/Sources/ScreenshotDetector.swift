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
    private let notificationCenter: NSNotificationCenter
    private let application: UIApplication
    private let imageManager: PHImageManager
    
    enum Error: ErrorType {
        case Unauthorized(status: PHAuthorizationStatus)
        case FetchFailure
        case LoadFailure
    }

    init(notificationCenter: NSNotificationCenter = .defaultCenter(), application: UIApplication = .sharedApplication(), imageManager: PHImageManager = .defaultManager()) {
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
                self.fail()
            }
        }
    }
    
    private func findScreenshot() {
        guard let screenshot = PHFetchResult.lastScreenshotFetchResult().firstObject as? PHAsset else {
            fail()
            return }

        imageManager.requestImageForAsset(screenshot, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.Default, options: nil) { (image, info) -> Void in
            
        }
    }
    
    private func fail() {
    
    }
}

protocol ScreenshotDetectorDelegate: class {
    func screenshotDetector(screenshotDetector: ScreenshotDetector, didDetectScreenshot: UIImage)
    func screenshotDetector(screenshotDetector: ScreenshotDetector, didFailWithError: ScreenshotDetector.Error)
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
