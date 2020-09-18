//
//  RequestScreenshotCell.swift
//  PinpointKit
//
//  Created by Twig on 9/16/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import UIKit

/// A cell that displays a button allowing a user to select a screenshot from their library.
class RequestScreenshotCell: UITableViewCell {

    // MARK: - RequestScreenshotCell
    
    /// A type of closure that is invoked when a button is tapped.
    typealias TapHandler = (_ button: UIButton) -> Void

    /// A struct encapsulating the information necessary for this view to be displayed.
    struct ViewModel {
        
        /// The text displayed in the button requesting a screenshot.
        let buttonText: String
        
        /// The font for the text in the button that is requesting a screenshot.
        let buttonFont: UIFont?
    }
    
    private enum DesignConstants {
        static let buttonHeight: CGFloat = 54.0
        static let topInset: CGFloat = 80.0
        static let horizontalInset: CGFloat = 32.0
    }
    
    /// A closure that is invoked when the user taps on the button.
    var screenshotButtonTapHandler: TapHandler?
    
    /// Set the `viewModel` in order to update the receiver’s content.
    var viewModel: ViewModel? {
        didSet {
            requestScreenshotButton.setTitle(viewModel?.buttonText, for: .normal)
            requestScreenshotButton.titleLabel?.font = viewModel?.buttonFont
        }
    }
    
    private lazy var requestScreenshotButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = DesignConstants.buttonHeight / 2.0

        return button
    }()

    // MARK: - UIView
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    override func addSubview(_ view: UIView) {
        // Prevents the adding of separators to this cell.
        let separatorHeight = UIScreen.main.pixelHeight
        guard view.frame.height != separatorHeight else {
            return
        }
        
        super.addSubview(view)
    }

    // MARK: - UITableViewCell
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    // MARK: - RequestScreenshotCell
    
    private func setUp() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(requestScreenshotButton)
        
        setupRequestButton()
    }
    
    private func setupRequestButton() {
        requestScreenshotButton.addTarget(self, action: #selector(screenshotButtonTapped), for: .primaryActionTriggered)
        
        NSLayoutConstraint.activate([
            requestScreenshotButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DesignConstants.topInset),
            requestScreenshotButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            requestScreenshotButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignConstants.horizontalInset),
            requestScreenshotButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignConstants.horizontalInset)
        ])
    }
    
    @objc private func screenshotButtonTapped(_ sender: UIButton) {
        screenshotButtonTapHandler?(sender)
    }
}
