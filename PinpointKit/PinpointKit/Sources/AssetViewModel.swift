//
//  AssetViewModel.swift
//  Pinpoint
//
//  Created by Caleb Davenport on 3/28/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit
import Photos

public final class AssetViewModel: NSObject {

    // MARK: - Properties

    public let imageManager: PHImageManager

    public let asset: PHAsset

    // MARK: - Initializers

    public init(imageManager: PHImageManager, asset: PHAsset) {
        self.imageManager = imageManager
        self.asset = asset
    }
    
    // MARK: - Helpers
    
    // TODO figure out cancelation
    public func requestImage(completion: UIImage? -> ()) {
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        imageManager.requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: options) { image, _ in
            completion(image)
        }
    }

}
