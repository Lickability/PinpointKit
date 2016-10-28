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
    private weak var delegate: FeedbackTableViewDataSourceDelegate?
    
    /**
     Initializes the data source with a configuration and a boolean value indicating whether the user has enabled log collection.
     
     - parameter interfaceCustomization:   The interface customization used to set up the data source.
     - parameter screenshot:               The screenshot to display for annotating.
     - parameter logSupporting:            The object the controls the support of logging.
     - parameter userEnabledLogCollection: A boolean value indicating whether the user has enabled log collection.
     - parameter delegate:                 The object informed when a screenshot is tapped.
     */
    init(interfaceCustomization: InterfaceCustomization, screenshot: UIImage, logSupporting: LogSupporting, userEnabledLogCollection: Bool, delegate: FeedbackTableViewDataSourceDelegate? = nil) {
        sections = self.dynamicType.sectionsFromConfiguration(interfaceCustomization, screenshot: screenshot, logSupporting: logSupporting, userEnabledLogCollection: userEnabledLogCollection)
        self.delegate = delegate
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
        case Screenshot(screensot: UIImage, hintText: String?, hintFont: UIFont)
        case CollectLogs(enabled: Bool, title: String, font: UIFont, canView: Bool)
    }
    
    // MARK: - FeedbackTableViewDataSource
    
    private static func sectionsFromConfiguration(interfaceCustomization: InterfaceCustomization, screenshot: UIImage, logSupporting: LogSupporting, userEnabledLogCollection: Bool) -> [Section] {
        guard logSupporting.logCollector != nil else { return [] }
        
        let screenshotRow = Row.Screenshot(screensot: screenshot, hintText: interfaceCustomization.interfaceText.feedbackEditHint, hintFont: interfaceCustomization.appearance.feedbackEditHintFont)
        let screenshotSection = Section.Feedback(rows: [screenshotRow])
        
        let collectLogsRow = Row.CollectLogs(enabled: userEnabledLogCollection, title: interfaceCustomization.interfaceText.logCollectionPermissionTitle, font: interfaceCustomization.appearance.logCollectionPermissionFont, canView: logSupporting.logViewer != nil)
        let collectLogsSection = Section.Feedback(rows: [collectLogsRow])
        
        return [screenshotSection, collectLogsSection]
    }
  
    private func checkmarkCell(forRow row: Row) -> CheckmarkCell {
        let cell = CheckmarkCell()
        
        guard case let .CollectLogs(enabled, title, font, canView) = row else {
            assertionFailure("Found unexpected row type when creating checkmark cell.")
            return cell
        }
        
        cell.textLabel?.text = title
        cell.textLabel?.font = font
        cell.accessoryType = canView ? .DetailButton : .None
        cell.isChecked = enabled
        
        return cell
    }
    
    private func screenshotCell(forRow row: Row) -> ScreenshotCell {
        let cell = ScreenshotCell()
        
        guard case let .Screenshot(screenshot, hintText, hintFont) = row else {
            assertionFailure("Found unexpected row type when creating screenshot cell.")
            return cell
        }
        
        cell.viewModel = ScreenshotCell.ViewModel(screenshot: screenshot, hintText: hintText, hintFont: hintFont)
        cell.screenshotButtonTapHandler = { [weak self] button in
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.feedbackTableViewDataSource(strongSelf, didTapScreenshot: screenshot)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch section {
        case let .Feedback(rows):
            let row = rows[indexPath.row]
            
            switch row {
            case .Screenshot:
                return screenshotCell(forRow: row)
            case .CollectLogs:
                return checkmarkCell(forRow: row)
            }
        }
    }
}

/// Delegate protocol describing a type that is informed of screenshot tapping events.
protocol FeedbackTableViewDataSourceDelegate: class {
    
    /**
     Notifies the delegate when a screenshot is tapped.
     
     - parameter feedbackTableViewDataSource: The feedback table view data source that sent the message.
     - parameter screenshot:                  The screenshot that was tapped.
     */
    func feedbackTableViewDataSource(feedbackTableViewDataSource: FeedbackTableViewDataSource, didTapScreenshot screenshot: UIImage)
}
