//
//  NSBundle+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 3/20/16.
//
//

import Foundation

/// Extends `NSBundle` to provide bundles from PinpointKit.
extension NSBundle {
    
    /**
     The main PinpointKit bundle.
     
     - returns: Returns the bundle associated with PinpointKit.
     */
    static func pinpointKitBundle() -> NSBundle {
        return NSBundle(forClass: PinpointKit.self)
    }
}
