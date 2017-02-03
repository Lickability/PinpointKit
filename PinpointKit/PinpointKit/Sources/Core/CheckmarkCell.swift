//
//  CheckmarkCell.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 3/18/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A `UITableViewCell` subclass that displays a checkmark in the `imageView` when `isChecked` is `true` and hides it, leaving a space when `false`.
final class CheckmarkCell: UITableViewCell {
    
    /// Controls whether the receiver displays a checkmark in `imageView`.
    var isChecked: Bool = false {
        didSet {
            imageView?.isHidden = !isChecked
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageView?.image = UIImage(named: "Checkmark", in: Bundle(for: type(of: self)), compatibleWith: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
