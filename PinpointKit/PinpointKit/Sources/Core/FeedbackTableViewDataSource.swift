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
        sections = type(of: self).sectionsFromConfiguration(interfaceCustomization, screenshot: screenshot, logSupporting: logSupporting, userEnabledLogCollection: userEnabledLogCollection)
        self.delegate = delegate
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
        var sections: [Section] = []
        
        let screenshotRow = Row.screenshot(screensot: screenshot, hintText: interfaceCustomization.interfaceText.feedbackEditHint, hintFont: interfaceCustomization.appearance.feedbackEditHintFont)
        let screenshotSection = Section.feedback(rows: [screenshotRow])
        
        sections.append(screenshotSection)
        
        if logSupporting.logCollector != nil {
            let collectLogsRow = Row.collectLogs(enabled: userEnabledLogCollection, title: interfaceCustomization.interfaceText.logCollectionPermissionTitle, font: interfaceCustomization.appearance.logCollectionPermissionFont, canView: logSupporting.logViewer != nil)
            let collectLogsSection = Section.feedback(rows: [collectLogsRow])
            
            sections.append(collectLogsSection)
        }
        
        return sections
    }
    
    private func checkmarkCell(for row: Row) -> CheckmarkCell {
        let cell = CheckmarkCell()

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
    
    private func screenshotCell(for row: Row) -> ScreenshotCell {
        let cell = ScreenshotCell()
        
        guard case let .screenshot(screenshot, hintText, hintFont) = row else {
            assertionFailure("Found unexpected row type when creating screenshot cell.")
            return cell
        }
        
        cell.viewModel = ScreenshotCell.ViewModel(screenshot: screenshot, hintText: hintText, hintFont: hintFont)
        cell.screenshotButtonTapHandler = { [weak self] button in
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.feedbackTableViewDataSource(feedbackTableViewDataSource: strongSelf, didTapScreenshot: screenshot)
        }
        
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
        
        switch section {
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

/// Delegate protocol describing a type that is informed of screenshot tapping events.
protocol FeedbackTableViewDataSourceDelegate: class {
    
    /**
     Notifies the delegate when a screenshot is tapped.
     
     - parameter feedbackTableViewDataSource: The feedback table view data source that sent the message.
     - parameter screenshot:                  The screenshot that was tapped.
     */
    func feedbackTableViewDataSource(feedbackTableViewDataSource: FeedbackTableViewDataSource, didTapScreenshot screenshot: UIImage)
}
