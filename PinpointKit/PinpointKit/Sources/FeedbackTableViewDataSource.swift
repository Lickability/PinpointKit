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
        sections = type(of: self).sectionsFromConfiguration(interfaceCustomization, logSupporting: logSupporting, userEnabledLogCollection: userEnabledLogCollection)
    }
    
    private enum Section {
        case feedback(rows: [Row])
        
        var numberOfRows: Int {
            switch self {
            case let .feedback(rows):
                return rows.count
            }
        }
    }
    
    private enum Row {
        case collectLogs(enabled: Bool, title: String, font: UIFont, canView: Bool)
    }
    
    // MARK: - FeedbackTableViewDataSource
    
    private static func sectionsFromConfiguration(_ interfaceCustomization: InterfaceCustomization, logSupporting: LogSupporting, userEnabledLogCollection: Bool) -> [Section] {
        guard logSupporting.logCollector != nil else { return [] }
        
        let collectLogsRow = Row.collectLogs(enabled: userEnabledLogCollection, title: interfaceCustomization.interfaceText.logCollectionPermissionTitle, font: interfaceCustomization.appearance.logCollectionPermissionFont, canView: logSupporting.logViewer != nil)
        let feedbackSection = Section.feedback(rows: [collectLogsRow])
        
        return [feedbackSection]
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CheckmarkCell()
        let section = sections[indexPath.section]
        
        switch section {
        case let .feedback(rows):
            let row = rows[indexPath.row]
            
            switch row {
            case let .collectLogs(enabled, title, font, canView):
                cell.textLabel?.text = title
                cell.textLabel?.font = font
                cell.accessoryType = canView ? .detailButton : .none
                cell.isChecked = enabled
            }
        }
        
        return cell
    }
}
