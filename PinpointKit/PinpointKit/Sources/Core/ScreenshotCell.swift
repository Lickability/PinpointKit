//
//  ScreenshotCell.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A view that displays a screenshot and hint text about how to edit it.
class ScreenshotCell: UITableViewCell {
    
    /// A type of closure that is invoked when a button is tapped.
    typealias TapHandler = (_ button: UIButton) -> Void
    
    /**
     *  A struct encapsulating the information necessary for this view to be displayed.
     */
    struct ViewModel {
        let screenshot: UIImage
        let hintText: String?
        let hintFont: UIFont?
    }
    
    private enum DesignConstants: CGFloat {
        case defaultMargin = 15
        case minimumScreenshotPadding = 50
    }
    
    /// Set the `viewData` in order to update the receiver’s content.
    var viewModel: ViewModel? {
        didSet {
            screenshotButton.setImage(viewModel?.screenshot.withRenderingMode(.alwaysOriginal), for: UIControlState())
            
            if let screenshot = viewModel?.screenshot {
                screenshotButtonHeightConstraint = screenshotButton.heightAnchor.constraint(equalTo: screenshotButton.widthAnchor, multiplier: 1.0 / screenshot.aspectRatio)
            }
            
            hintLabel.text = viewModel?.hintText
            hintLabel.isHidden = viewModel?.hintText == nil || viewModel?.hintText?.isEmpty == true
            hintLabel.font = viewModel?.hintFont
        }
    }
    
    /// A closure that is invoked when the user taps on the screenshot.
    var screenshotButtonTapHandler: TapHandler?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.layoutMargins = UIEdgeInsets(top: DesignConstants.defaultMargin.rawValue, left: DesignConstants.defaultMargin.rawValue, bottom: DesignConstants.defaultMargin.rawValue, right: DesignConstants.defaultMargin.rawValue)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        return stackView
    }()
    
    private lazy var screenshotButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = self.tintColor.cgColor
        button.layer.borderWidth = 1
        
        return button
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    private var screenshotButtonHeightConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            screenshotButtonHeightConstraint?.isActive = true
        }
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    // MARK: - UIView
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        screenshotButton.layer.borderColor = tintColor.cgColor
    }
    
    override func addSubview(_ view: UIView) {
        // Prevents the adding of separators to this cell.
        let separatorHeight = UIScreen.main.pixelHeight
        guard view.frame.height != separatorHeight else {
            return
        }
        
        super.addSubview(view)
    }
    
    // MARK: - ScreenshotCell
    
    private func setUp() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        stackView.addArrangedSubview(screenshotButton)
        stackView.addArrangedSubview(hintLabel)
        
        setUpScreenshotButton()
    }
    
    private func setUpScreenshotButton() {
        screenshotButton.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.leadingAnchor, constant: DesignConstants.minimumScreenshotPadding.rawValue).isActive = true
        screenshotButton.trailingAnchor.constraint(lessThanOrEqualTo: stackView.trailingAnchor, constant: -DesignConstants.minimumScreenshotPadding.rawValue).isActive = true
        
        screenshotButtonHeightConstraint = screenshotButton.heightAnchor.constraint(equalTo: screenshotButton.widthAnchor, multiplier: 1.0)
        
        screenshotButton.addTarget(self, action: #selector(ScreenshotCell.screenshotButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func screenshotButtonTapped(_ sender: UIButton) {
        screenshotButtonTapHandler?(sender)
    }
}

private extension UIImage {
    var aspectRatio: CGFloat {
        guard size.height > 0 else { return 0 }
        
        return size.width / size.height
    }
}
