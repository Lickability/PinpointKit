//
//  BasicLogViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

public class BasicLogViewController: UIViewController, LogViewer {
    
    var interfaceCustomization: InterfaceCustomization?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.editable = false
        
        textView.font = UIFont(name: "Menlo-Regular", size: 12)
        
        return textView
    }()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Console Log"
    }
    
    private func setUpTextView() {
        view.addSubview(textView)
        
        textView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: 0).active = true
        textView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: 0).active = true
        textView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: 0).active = true
        textView.heightAnchor.constraintEqualToAnchor(view.heightAnchor, constant: 0).active = true

    }
    
    // MARK: - LogViewer
    
    public func viewLog(collector: LogCollector, fromViewController viewController: UIViewController) {
        textView.text = collector.retrieveLogs(fromOffsetSinceNow: nil).joinWithSeparator("\n")
        
        viewController.showViewController(self, sender: viewController)
    }
}
