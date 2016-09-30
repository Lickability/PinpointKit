//
//  LogViewer.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A protocol describing an interface to an object that can view a console log.
public protocol LogViewer: InterfaceCustomizable {
    
    /**
     Displays a log from a given view controller.
     
     - parameter collector:      The collector which has the logs to view.
     - parameter viewController: A view controller from which to present an interface for log viewing.
     */
    func viewLog(in collector: LogCollector, from viewController: UIViewController)
}
