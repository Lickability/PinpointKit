//
//  FeedbackTableViewDataSource.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// An object conforming to `UITableViewDataSource` that acts as the data source for a `FeedbackViewController`.
final class FeedbackTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let sections: [Section]
    
    /**
     Initializes the data source with a configuration and a boolean value indicating whether the user has enabled log collection.
     
     - parameter interfaceCustomization:   The interface customization used to set up the data source.
     - parameter logSupporting:            The object the controls the support of logging.
     - parameter userEnabledLogCollection: A boolean value indicating whether the user has enabled log collection.
     */
    init(interfaceCustomization: InterfaceCustomization, logSupporting: LogSupporting, userEnabledLogCollection: Bool) {
        sections = self.dynamicType.sectionsFromConfiguration(interfaceCustomization, logSupporting: logSupporting, userEnabledLogCollection: userEnabledLogCollection)
    }
    
    private enum Section {
        case Feedback(rows: [Row])
        
        var numberOfRows: Int {
            switch self {
            case let .Feedback(rows):
                return rows.count
            }
        }
    }
    
    private enum Row {
        case CollectLogs(enabled: Bool, title: String, font: UIFont, canView: Bool)
    }
    
    // MARK: - FeedbackTableViewDataSource
    
    private static func sectionsFromConfiguration(interfaceCustomization: InterfaceCustomization, logSupporting: LogSupporting, userEnabledLogCollection: Bool) -> [Section] {
        guard logSupporting.logCollector != nil else { return [] }
        
        let collectLogsRow = Row.CollectLogs(enabled: userEnabledLogCollection, title: interfaceCustomization.interfaceText.logCollectionPermissionTitle, font: interfaceCustomization.appearance.logCollectionPermissionFont, canView: logSupporting.logViewer != nil)
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
        let cell = CheckmarkCell()
        let section = sections[indexPath.section]
        
        switch section {
        case let .Feedback(rows):
            let row = rows[indexPath.row]
            
            switch row {
            case let .CollectLogs(enabled, title, font, canView):
                cell.textLabel?.text = title
                cell.textLabel?.font = font
                cell.accessoryType = canView ? .DetailButton : .None
                cell.isChecked = enabled
            }
        }
        
        return cell
    }
}
