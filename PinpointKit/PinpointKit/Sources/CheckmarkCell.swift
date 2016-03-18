//
//  CheckmarkCell.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 3/18/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

final class CheckmarkCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageView?.image = UIImage(named: "Checkmark", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var isChecked: Bool = false {
        didSet {
            imageView?.hidden = !isChecked
        }
    }
}
