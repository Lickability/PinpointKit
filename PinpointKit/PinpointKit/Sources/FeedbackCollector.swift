//
//  FeedbackCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

public protocol FeedbackCollector {
    var feedbackDelegate: FeedbackCollectorDelegate? { get set }
    var configuration: Configuration? { get set }
}

public protocol FeedbackCollectorDelegate: class {
    func feedbackCollector(feedbackCollector: FeedbackCollector, didCollectFeedback feedback: Feedback)
}
