//
//  CreateSubpageViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 4/21/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class CreateSubpageViewController: UIViewController, UITextFieldDelegate {

    var projectManager: Polaris!
    @IBOutlet var textField: UITextField!
    
    weak var delegate: NewFilesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func saveDidPush(_ sender: UIBarButtonItem) {
        if textField.text!.isEmpty {
            textField.becomeFirstResponder()
        }
        else {
            
            let dirUrl = try! projectManager.inspectorURL.appendingPathComponent(textField.text!, isDirectory: true)
            
            let fileManager = FileManager.default
            
            // Create folder
            do {
                try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Something went wrong.", viewController: self)
                
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            
            
            let indexFileBody = FileTemplates.htmlTemplateFile(forName: textField.text!)
            let indexFileUrl = try! dirUrl.appendingPathComponent("index.html", isDirectory: false)

            
            // Create file
            do {
                try indexFileBody?.write(to: indexFileUrl, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Something went wrong", viewController: self)
                
                self.dismiss(animated: true, completion: nil)
                return

            }
            
            
            delegate?.reloadDataWithSelection(true)
            self.dismiss(animated: true, completion: nil)
            
            
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    @IBAction func cancelDidPush() {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
