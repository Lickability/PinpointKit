//
//  ScreenshotHeaderView.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class ScreenshotHeaderView: UIView {
    
    typealias TapHandler = (button: UIButton) -> Void
    
    struct ViewData {
        let screenshot: UIImage
        let hintText: String?
    }
    
    private enum DesignConstants: CGFloat {
        case DefaultMargin = 15
        case MinimumScreenshotPadding = 50
    }
    
    var viewData: ViewData? {
        didSet {
            
            screenshotButton.setImage(viewData?.screenshot, forState: .Normal)
            
            if let screenshot = viewData?.screenshot {
                screenshotButtonHeightConstraint = screenshotButton.heightAnchor.constraintEqualToAnchor(screenshotButton.widthAnchor, multiplier: 1.0 / screenshot.aspectRatio)
            }
            
            hintLabel.text = viewData?.hintText
        }
    }
    
    var screenshotButtonTapHandler: TapHandler?
    
    private let stackView = UIStackView()
    
    private let screenshotButton = UIButton()
    private let hintLabel = UILabel()
    
    private var screenshotButtonHeightConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.active = false
            screenshotButtonHeightConstraint?.active = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
    
    private func setUp() {
        setUpStackView()
        addSubview(stackView)
        
        stackView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        
        stackView.addArrangedSubview(screenshotButton)
        stackView.addArrangedSubview(hintLabel)
        
        setUpScreenshotButton()
    }
    
    private func setUpStackView() {
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.layoutMargins = UIEdgeInsets(top: DesignConstants.DefaultMargin.rawValue, left: DesignConstants.DefaultMargin.rawValue, bottom: DesignConstants.DefaultMargin.rawValue, right: DesignConstants.DefaultMargin.rawValue)
        stackView.layoutMarginsRelativeArrangement = true
    }
    
    private func setUpScreenshotButton() {
        screenshotButton.leadingAnchor.constraintGreaterThanOrEqualToAnchor(stackView.leadingAnchor, constant: DesignConstants.MinimumScreenshotPadding.rawValue).active = true
        screenshotButton.trailingAnchor.constraintLessThanOrEqualToAnchor(stackView.trailingAnchor, constant: -DesignConstants.MinimumScreenshotPadding.rawValue).active = true
        
        screenshotButtonHeightConstraint = screenshotButton.heightAnchor.constraintEqualToAnchor(screenshotButton.widthAnchor, multiplier: 1.0)
        
        screenshotButton.addTarget(self, action: "screenshotButtonTapped:", forControlEvents: .TouchUpInside)
    }
    
    @objc private func screenshotButtonTapped(sender: UIButton) {
        screenshotButtonTapHandler?(button: sender)
    }
}

private extension UIImage {
    
    var aspectRatio: CGFloat {
        return size.width / size.height
    }
}
