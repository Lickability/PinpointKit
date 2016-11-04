//
//  ViewController.swift
//  PinpointKitExample
//
//  Created by Paul Rehkugler on 2/7/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PinpointKit

final class ViewController: UITableViewController {
    
    fileprivate let pinpointKit = PinpointKit(configuration: Configuration(editor: {
        
        // Create a custom editor
        let editImageViewController = EditImageViewController()
        
        
        // Associate that custom bar button item provider with the ditor.
        editImageViewController.barButtonItemProvider = MyButtonProvider(editImageViewController: editImageViewController)
        
        return editImageViewController
        
        }(), feedbackConfiguration: FeedbackConfiguration(recipients: ["example@something.com"]))
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides the infinite cells footer.
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pinpointKit.show(from: self)
    }
}

// Create a custom bar button item provider class
class MyButtonProvider: EditImageViewControllerBarButtonItemProviding {
    private weak var editImageViewController: EditImageViewController?
    
    init(editImageViewController: EditImageViewController) {
        self.editImageViewController = editImageViewController
    }
    
    lazy var leftBarButtonItem: UIBarButtonItem? = UIBarButtonItem(title: "CLOSE!", style: .done, target: self, action: #selector(MyButtonProvider.close(sender:)))
    
    
    lazy var rightBarButtonItem: UIBarButtonItem? = UIBarButtonItem(title: "LOG!", style: .plain, target: self, action: #selector(MyButtonProvider.logSomething(sender:)))
    
    let allowsHidingBarButtonItemsWhileEditingTextAnnotations: Bool = true
    
    @objc private func close(sender: UIBarButtonItem) {
        self.editImageViewController?.attemptToDismiss(animated: true)
    }
    
    @objc private func logSomething(sender: UIBarButtonItem) {
        print("HEY")
    }
}
