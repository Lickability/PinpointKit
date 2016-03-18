//
//  CheckmarkCell.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 3/18/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

final class CheckmarkCell: UITableViewCell {
    var isChecked: Bool = false {
        didSet {
            imageView?.image = isChecked ? UIImage(named: "Checkmark") : nil
        }
    }
}
