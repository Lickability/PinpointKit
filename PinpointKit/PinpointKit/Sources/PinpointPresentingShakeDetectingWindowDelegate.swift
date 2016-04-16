//
//  PinpointPresentingShakeDetectingWindowDelegate.swift
//  PinpointKit
//
//  Created by Paul Rehkugler on 4/16/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import Foundation

public final class PinpointPresentingShakeDetectingWindowDelegate: ShakeDetectingWindowDelegate {

    private let pinpointKit: PinpointKit
    public init(pinpointKit: PinpointKit) {
        self.pinpointKit = pinpointKit
    }

    // MARK: - ShakeDetectingWindowDelegate

    public func shakeDetectingWindowDidDetectShake(shakeDetectingWindow: ShakeDetectingWindow) {
        guard let rootViewController = shakeDetectingWindow.rootViewController else {
            print("PinpointPresentingShakeDetectingWindowDelegate couldn't find a root view controller to present on.")
            return
        }

        pinpointKit.show(fromViewController: rootViewController)
    }
}