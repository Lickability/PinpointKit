//
//  NSBundle+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 3/20/16.
//
//

import Foundation

/// Extends `Bundle` to provide bundles from PinpointKit.
extension Bundle {
    
    /**
     The main PinpointKit bundle.
     
     - returns: Returns the bundle associated with PinpointKit.
     */
    static func pinpointKitBundle() -> Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: PinpointKit.self)
        #endif
    }
}
