//
//  CreateDirViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 21/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class CreateDirViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: NewFilesDelegate?
    var projectManager: Polaris!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
    }
    
    @IBAction func saveDidPush() {
        if textField.text!.isEmpty {
            textField.becomeFirstResponder()
        } else {
            
            // Create dir
            
            let dirUrl = projectManager.inspectorURL.appendingPathComponent(textField.text!, isDirectory: true)
            
            let fileManager = FileManager.default
            do {
                try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Something went wrong", viewController: self)
            }
            
            self.dismiss(animated: true, completion: { 
                self.delegate?.reloadDataWithSelection(true)
            })
            
        }
    }
    
    @IBAction func cancelDidPush() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveDidPush()

        return false
    }
    
    
}
