//
//  ViewController.swift
//  PinpointKitExample
//
//  Created by Paul Rehkugler on 2/7/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PinpointKit

final class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides the infinite cells footer.
        tableView.tableFooterView = UIView()
    }
}
