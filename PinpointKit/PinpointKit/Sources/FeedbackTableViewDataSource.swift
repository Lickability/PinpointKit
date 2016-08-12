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
     - parameter screenshot:               The screenshot to display for annotating.
     - parameter logSupporting:            The object the controls the support of logging.
     - parameter userEnabledLogCollection: A boolean value indicating whether the user has enabled log collection.
     */
    init(interfaceCustomization: InterfaceCustomization, screenshot: UIImage, logSupporting: LogSupporting, userEnabledLogCollection: Bool) {
        sections = self.dynamicType.sectionsFromConfiguration(interfaceCustomization, screenshot: screenshot, logSupporting: logSupporting, userEnabledLogCollection: userEnabledLogCollection)
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
        case screenshot(screensot: UIImage, hintText: String?, hintFont: UIFont)
        case collectLogs(enabled: Bool, title: String, font: UIFont, canView: Bool)
    }
    
    // MARK: - FeedbackTableViewDataSource
    
    private static func sectionsFromConfiguration(_ interfaceCustomization: InterfaceCustomization, screenshot: UIImage, logSupporting: LogSupporting, userEnabledLogCollection: Bool) -> [Section] {
        guard logSupporting.logCollector != nil else { return [] }
        
        let screenshotRow = Row.screenshot(screensot: screenshot, hintText: interfaceCustomization.interfaceText.feedbackEditHint, hintFont: interfaceCustomization.appearance.feedbackEditHintFont)
        let screenshotSection = Section.feedback(rows: [screenshotRow])
        
        let collectLogsRow = Row.collectLogs(enabled: userEnabledLogCollection, title: interfaceCustomization.interfaceText.logCollectionPermissionTitle, font: interfaceCustomization.appearance.logCollectionPermissionFont, canView: logSupporting.logViewer != nil)
        let collectLogsSection = Section.feedback(rows: [collectLogsRow])
        
        return [screenshotSection, collectLogsSection]
    }
    
    private func checkmarkCell(for row: Row) -> CheckmarkCell {
        let cell = CheckmarkCell() // TODO: dequeue instead.

        guard case let .collectLogs(enabled, title, font, canView) = row else {
            assertionFailure("Found unexpected row type when creating checkmark cell.")
            return cell
        }
        
        cell.textLabel?.text = title
        cell.textLabel?.font = font
        cell.accessoryType = canView ? .detailButton : .none
        cell.isChecked = enabled
        
        return cell
    }
    
    private func screenshotCell(for row: Row) -> ScreenshotHeaderView {
        let cell = ScreenshotHeaderView() // TODO: dequeue instead.
        
        guard case let .screenshot(screenshot, hintText, hintFont) = row else {
            assertionFailure("Found unexpected row type when creating screenshot cell.")
            return cell
        }
        
        cell.viewModel = ScreenshotHeaderView.ViewModel(screenshot: screenshot, hintText: hintText, hintFont: hintFont)
        
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch sections[indexPath.section] {
        case let .feedback(rows):
            let row = rows[indexPath.row]
            switch row {
            case .screenshot:
                return screenshotCell(for: row)
            case .collectLogs:
                return checkmarkCell(for: row)
            }
        }
    }
}
