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
    
    /// A property that controls whether the receiver displays a checkmark in the `imageView`.
    var isChecked: Bool = false {
        didSet {
            imageView?.hidden = !isChecked
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageView?.image = UIImage(named: "Checkmark", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
