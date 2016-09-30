//
//  NSBundle+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 3/20/16.
//
//

import Foundation

/// Extends `NSBundle` to provide bundles from PinpointKit.
extension Bundle {
    
    /**
     The main PinpointKit bundle.
     
     - returns: Returns the bundle associated with PinpointKit.
     */
    static func pinpointKitBundle() -> Bundle {
        return Bundle(for: PinpointKit.self)
    }
}
