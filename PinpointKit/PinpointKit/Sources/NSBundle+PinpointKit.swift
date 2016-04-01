//
//  NSBundle+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 3/20/16.
//
//

import Foundation

extension NSBundle {
    static func pinpointKitBundle() -> NSBundle {
        return NSBundle(forClass: PinpointKit.self)
    }
}
