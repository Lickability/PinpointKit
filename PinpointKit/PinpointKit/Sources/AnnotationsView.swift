//
//  AnnotationsView.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/7/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

/// A `UIView` subclass that displays annotations.
class AnnotationsView: UIView {
    override func addSubview(view: UIView) {
        super.addSubview(view)
        moveViewIfAppropriate(view)
    }
    
    override func bringSubviewToFront(view: UIView) {
        super.bringSubviewToFront(view)
        moveViewIfAppropriate(view)
    }
    
    /**
     Calls `moveBlurViewAboveBlurViewsAndUnderOthers(blurView:)`, passing `view`, but only if `view` is a `BlurAnnotationView`.
     
     - parameter view: The view to potentially move.
     */
    func moveViewIfAppropriate(view: UIView) {
        if let blurView = view as? BlurAnnotationView {
            moveBlurViewAboveBlurViewsAndUnderOthers(blurView: blurView)
        }
    }
    
    /**
     Moves the blur view passed in above other subviews that are blur views, but beneath other subviews.
     
     - parameter blurView: The blur view to move.
     */
    func moveBlurViewAboveBlurViewsAndUnderOthers(blurView blurView: BlurAnnotationView) {
        var lastBlurViewIndex: Int?
        for (index, subview) in subviews.enumerate() {
            if subview is BlurAnnotationView && subview as? BlurAnnotationView != blurView {
                lastBlurViewIndex = index
            }
        }
        
        let index = lastBlurViewIndex?.successor() ?? 0
        insertSubview(blurView, atIndex: index)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        // In certain cases, subviews would otherwise revert to the system default `tintColor`.
        // One such case occurs when an alert controller is shown followed by dismissing and re-presenting
        // a view controller containing an `AnnotationsView` when the `AnnotationsView` has a custom 
        // (non-inherited) `tintColor`.
        for subview in subviews {
            subview.tintColor = tintColor
        }
    }
}
