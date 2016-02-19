//
//  ScreenshotHeaderView.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class ScreenshotHeaderView: UIView {
    
    struct ViewData {
        let screenshot: UIImage
        let hintText: String?
    }
    
    var viewData: ViewData? {
        didSet {
            screenshotButton.setImage(viewData?.screenshot, forState: .Normal)
            hintLabel.text = viewData?.hintText
        }
    }
    
    let stackView = UIStackView()
    
    let screenshotButton = UIButton()
    let hintLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        stackView.topAnchor.constraintEqualToAnchor(layoutMarginsGuide.topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(layoutMarginsGuide.bottomAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(layoutMarginsGuide.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(layoutMarginsGuide.trailingAnchor).active = true
        
        stackView.addArrangedSubview(screenshotButton)
        stackView.addArrangedSubview(hintLabel)
        
        screenshotButton.leadingAnchor.constraintEqualToAnchor(stackView.leadingAnchor, constant: 50).active = true
        screenshotButton.trailingAnchor.constraintEqualToAnchor(stackView.trailingAnchor, constant: -50).active = true
    }
}
