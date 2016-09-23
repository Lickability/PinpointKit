//
//  BasicLogViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// The default view controller for the text log.
open class BasicLogViewController: UIViewController, LogViewer {
    
    // MARK: - InterfaceCustomizable
    
    open var interfaceCustomization: InterfaceCustomization? {
        didSet {
            title = interfaceCustomization?.interfaceText.logCollectorTitle
            textView.font = interfaceCustomization?.appearance.logFont
        }
    }
    
    // MARK: - BasicLogViewController
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes()

        return textView
    }()
    
    // MARK: - UIViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        func setUpTextView() {
            view.addSubview(textView)
            
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
            textView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0).isActive = true
        }
        
        setUpTextView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.scrollRangeToVisible(NSRange(location: (textView.text as NSString).length, length: 0))
    }
    
    // MARK: - LogViewer
    
    open func viewLog(in collector: LogCollector, from viewController: UIViewController) {
        let logText = collector.retrieveLogs().joined(separator: "\n")
        textView.text = logText
        
        viewController.show(self, sender: viewController)
    }
}
