//
//  ScreenshotHeaderView.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A view that displays a screenshot and hint text about how to edit it.
class ScreenshotHeaderView: UIView {
    
    /// A type of closure that is invoked when a button is tapped.
    typealias TapHandler = (button: UIButton) -> Void
    
    /**
     *  A struct encapsulating the information necessary for this view to be displayed.
     */
    struct ViewModel {
        let screenshot: UIImage
        let hintText: String?
        let hintFont: UIFont?
    }
    
    private enum DesignConstants: CGFloat {
        case DefaultMargin = 15
        case MinimumScreenshotPadding = 50
    }
    
    /// Set the `viewData` in order to update the receiver’s content.
    var viewModel: ViewModel? {
        didSet {
            screenshotButton.setImage(viewModel?.screenshot.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
            
            if let screenshot = viewModel?.screenshot {
                screenshotButtonHeightConstraint = screenshotButton.heightAnchor.constraintEqualToAnchor(screenshotButton.widthAnchor, multiplier: 1.0 / screenshot.aspectRatio)
            }
            
            hintLabel.text = viewModel?.hintText
            hintLabel.hidden = viewModel?.hintText == nil || viewModel?.hintText?.isEmpty == true
            hintLabel.font = viewModel?.hintFont
        }
    }
    
    /// A closure that is invoked when the user taps on the screenshot.
    var screenshotButtonTapHandler: TapHandler?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.layoutMargins = UIEdgeInsets(top: DesignConstants.DefaultMargin.rawValue, left: DesignConstants.DefaultMargin.rawValue, bottom: DesignConstants.DefaultMargin.rawValue, right: DesignConstants.DefaultMargin.rawValue)
        stackView.layoutMarginsRelativeArrangement = true
        
        return stackView
    }()
    
    private lazy var screenshotButton: UIButton = {
        let button = UIButton(type: .System)
        button.layer.borderColor = self.tintColor.CGColor
        button.layer.borderWidth = 1
        
        return button
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
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
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        screenshotButton.layer.borderColor = tintColor.CGColor
    }
    
    // MARK: - ScreenshotHeaderView
    
    private func setUp() {
        addSubview(stackView)
        
        stackView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        stackView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        
        stackView.addArrangedSubview(screenshotButton)
        stackView.addArrangedSubview(hintLabel)
        
        setUpScreenshotButton()
    }
    
    private func setUpScreenshotButton() {
        screenshotButton.leadingAnchor.constraintGreaterThanOrEqualToAnchor(stackView.leadingAnchor, constant: DesignConstants.MinimumScreenshotPadding.rawValue).active = true
        screenshotButton.trailingAnchor.constraintLessThanOrEqualToAnchor(stackView.trailingAnchor, constant: -DesignConstants.MinimumScreenshotPadding.rawValue).active = true
        
        screenshotButtonHeightConstraint = screenshotButton.heightAnchor.constraintEqualToAnchor(screenshotButton.widthAnchor, multiplier: 1.0)
        
        screenshotButton.addTarget(self, action: #selector(ScreenshotHeaderView.screenshotButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    @objc private func screenshotButtonTapped(sender: UIButton) {
        screenshotButtonTapHandler?(button: sender)
    }
}

private extension UIImage {
    var aspectRatio: CGFloat {
        guard size.height > 0 else { return 0 }
        
        return size.width / size.height
    }
}
