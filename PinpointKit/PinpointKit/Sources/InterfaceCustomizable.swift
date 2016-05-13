//
//  InterfaceCustomizable.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 5/13/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A protocol that defines that the conforming type must allow its interface to customized.
public protocol InterfaceCustomizable {
    
    /// The customizations to be applied to the conforming type.
    var interfaceCustomization: InterfaceCustomization? { get set }
}
