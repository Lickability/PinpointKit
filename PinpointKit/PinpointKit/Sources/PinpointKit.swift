//
//  PinpointKit.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 1/22/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

/**
*  `PinpointKit` is an object that can be used to collect feedback from application users.
*/
final class PinpointKit {
    struct Configuration {
    }

    /// Returns a `PinpointKit` instance with a default configuration.
    static let defaultPinpointKit = PinpointKit()

    /// The configuration struct that specifies how PinpointKit should be configured.
    private let configuration: Configuration
    
    /// A delegate that is notified of significant events.
    private weak var delegate: PinpointKitDelegate?
    
    /**
     Initializes a `PinpointKit` object with a configuration and an optional delegate.
     
     - parameter configuration: The configuration struct that specifies how PinpointKit should be configured.
     - parameter delegate:      A delegate that is notified of significant events.
     
     - returns: A fully initialized `PinpointKit` object.
     */
    init(configuration: Configuration = Configuration(), delegate: PinpointKitDelegate? = nil)  {
        self.configuration = configuration
        self.delegate = delegate
    }
}

/// A protocol describing an object that can be notified of events from PinpointKit.
protocol PinpointKitDelegate: class {

}
