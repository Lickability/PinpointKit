//
//  BasicLogViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// The default view controller for the text log.
public class BasicLogViewController: UIViewController, LogViewer {
    
    // MARK: - InterfaceCustomizable
    
    public var interfaceCustomization: InterfaceCustomization? {
        didSet {
            title = interfaceCustomization?.interfaceText.logCollectorTitle
            textView.font = interfaceCustomization?.appearance.logFont
        }
    }
    
    // MARK: - BasicLogViewController
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.editable = false
        textView.dataDetectorTypes = .None

        return textView
    }()
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        func setUpTextView() {
            view.addSubview(textView)
            
            textView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: 0).active = true
            textView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: 0).active = true
            textView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: 0).active = true
            textView.heightAnchor.constraintEqualToAnchor(view.heightAnchor, constant: 0).active = true
        }
        
        setUpTextView()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.scrollRangeToVisible(NSRange(location: (textView.text as NSString).length, length: 0))
    }
    
    // MARK: - LogViewer
    
    public func viewLog(collector: LogCollector, fromViewController viewController: UIViewController) {
        let logText = collector.retrieveLogs().joinWithSeparator("\n")
        textView.text = logText
        
        viewController.showViewController(self, sender: viewController)
    }
}
