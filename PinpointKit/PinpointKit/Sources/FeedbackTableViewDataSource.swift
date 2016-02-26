//
//  FeedbackTableViewDataSource.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

class FeedbackTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let sections: [Section]
    
    init(configuration: Configuration, userEnabledLogCollection: Bool) {
        sections = self.dynamicType.sectionsFromConfiguration(configuration, userEnabledLogCollection: userEnabledLogCollection)
    }
    
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
        case CollectLogs(enabled: Bool, title: String, canView: Bool)
    }
    
    // MARK: - FeedbackTableViewDataSource
    
    private static func sectionsFromConfiguration(configuration: Configuration, userEnabledLogCollection: Bool) -> [Section] {
        guard configuration.logCollector != nil else { return [] }
        
        let collectLogsRow = Row.CollectLogs(enabled: userEnabledLogCollection, title: configuration.interfaceText.logCollectionPermissionTitle, canView: configuration.logViewer != nil)
        let feedbackSection = Section.Feedback(rows: [collectLogsRow])
        
        return [feedbackSection]
    }
    
    // MARK: - UITableViewDataSource
    
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
            case let .CollectLogs(enabled, title, canView):
                cell.textLabel?.text = title
                cell.accessoryType = canView ? .DetailButton : .None
                //TODO: cell.imageview.image = checkmark
            }
        }
        
        return cell
    }
    
    
}
