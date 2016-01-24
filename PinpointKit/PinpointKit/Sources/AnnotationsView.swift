//
//  AnnotationsView.swift
//  Pinpoint
//
//  Created by Brian Capps on 5/7/15.
//  Copyright (c) 2015 Lickability. All rights reserved.
//

import UIKit

class AnnotationsView: UIView {
    override func addSubview(view: UIView) {
        super.addSubview(view)
        moveViewIfAppropriate(view)
    }
    
    override func bringSubviewToFront(view: UIView) {
        super.bringSubviewToFront(view)
        moveViewIfAppropriate(view)
    }
    
    func moveViewIfAppropriate(view: UIView) {
        if let blurView = view as? BlurAnnotationView {
            moveBlurViewAboveBlurViewsAndUnderOthers(blurView: blurView)
        }
    }
    
    func moveBlurViewAboveBlurViewsAndUnderOthers(blurView blurView: BlurAnnotationView) {
        var lastBlurViewIndex: Int?
        for (index, subview) in subviews.enumerate() {
            if subview is BlurAnnotationView && subview as? BlurAnnotationView != blurView {
                lastBlurViewIndex = index
            }
        }
        
        let index = lastBlurViewIndex.map { $0 + 1 } ?? 0
        insertSubview(blurView, atIndex: index)
    }
}
