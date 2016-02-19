//
//  FeedbackTableViewDataSource.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class FeedbackTableViewDataSource: NSObject, UITableViewDataSource {
    
    var sections: [Section] = [Section.Feedback(rows: [Row.CollectLogs(enabled: true, title: "Test")])]
    
    enum Section {
        case Feedback(rows: [Row])
        
        var numberOfRows: Int {
            switch self {
            case let .Feedback(rows):
                return rows.count
            }
        }
    }
    enum Row {
        case CollectLogs(enabled: Bool, title: String)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let section = sections[indexPath.section]
        
        switch section {
        case let .Feedback(rows):
            let row = rows[indexPath.row]
            
            switch row {
            case let .CollectLogs(enabled, title):
                cell.textLabel?.text = title
                cell.accessoryType = .DetailButton
                //TODO: cell.imageview.image = checkmark
            }
        }
        
        return cell
    }
    
    
}
