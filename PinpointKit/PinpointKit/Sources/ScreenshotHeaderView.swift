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
    
    typealias TapHandler = (button: UIButton) -> Void
    
    var viewData: ViewData? {
        didSet {
            screenshotButton.setImage(viewData?.screenshot, forState: .Normal)
            hintLabel.text = viewData?.hintText
        }
    }
    
    var screenshotButtonTapHandler: TapHandler?
    
    private let stackView = UIStackView()
    
    private let screenshotButton = UIButton()
    private let hintLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.topAnchor.constraintEqualToAnchor(layoutMarginsGuide.topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(layoutMarginsGuide.bottomAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(layoutMarginsGuide.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(layoutMarginsGuide.trailingAnchor).active = true
        
        stackView.addArrangedSubview(screenshotButton)
        stackView.addArrangedSubview(hintLabel)
        
        setUpScreenshotButton()
    }
    
    private func setUpScreenshotButton() {
        screenshotButton.leadingAnchor.constraintEqualToAnchor(stackView.leadingAnchor, constant: 50).active = true
        screenshotButton.trailingAnchor.constraintEqualToAnchor(stackView.trailingAnchor, constant: -50).active = true

        screenshotButton.addTarget(self, action: "screenshotButtonTapped:", forControlEvents: .TouchUpInside)
    }
    
    @objc private func screenshotButtonTapped(sender: UIButton) {
        screenshotButtonTapHandler?(button: sender)
    }
}
