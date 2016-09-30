//
//  LogSupporting.swift
//  PinpointKit
//
//  Created by Andrew Harrison on 5/13/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A model protocol that encapsulates the collection and viewing of logs.
public protocol LogSupporting {
    
    /// An optional type that collects logs to be displayed and sent with feedback.
    var logCollector: LogCollector? { get set }
    
    /// An optional type that allows the user to view logs before sending feedback.
    var logViewer: LogViewer? { get set }
}
