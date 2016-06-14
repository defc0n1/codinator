//
//  CreateFileViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 21/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class CreateFileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var extensionTextField: UITextField!
    
    var items: [String]?
    var path: String?
    
    weak var delegate: NewFilesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.becomeFirstResponder()
    }

    
    
    @IBAction func createFile(_ sender: UIBarButtonItem) {
        
        if extensionTextField.text!.isEmpty {
            extensionTextField.becomeFirstResponder()
            return
        }
        
        if nameTextField.text!.isEmpty {
            nameTextField.becomeFirstResponder()
            return
        }
        
        
        let fileName = NewFiles.availableName(nameTextField.text! + "." + extensionTextField.text!, nameWithoutExtension: nameTextField.text!, Extension: extensionTextField.text!, items: items!)
        
        var fileContent: String {
            
            switch extensionTextField.text! {
            case "html":
                return FileTemplates.htmlTemplateFile(forName: nameTextField.text!)

            case "css":
                return FileTemplates.cssTemplateFile()
                
            case "js":
                return FileTemplates.jsTemplateFile()
                
            case "txt":
                return FileTemplates.txtTemplateFile()
                
            case "php":
                return FileTemplates.phpTemplateFile()
                
            default:
                return ""
            }
            
        }
       
        
        let fileUrl = try! URL(fileURLWithPath: path!, isDirectory: false).appendingPathComponent(fileName)
        
        do {
            try fileContent.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Something went wrong", viewController: self)
            
            self.dismiss(animated: true, completion: nil)
        }
        
        
        self.dismiss(animated: true) { 
            self.delegate?.reloadDataWithSelection(true)
        }
        
        
    }
    
    
    @IBAction func cancelDidPush() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if extensionTextField.text!.isEmpty && nameTextField.text!.isEmpty {
            if extensionTextField.text!.isEmpty {
                extensionTextField.becomeFirstResponder()
            }
            
            if nameTextField.text!.isEmpty {
                nameTextField.becomeFirstResponder()
            }
        }
        else {
            createFile(UIBarButtonItem())
        }
        
        
        return false
    }
    
    
    // MARK: - File types Shortcut
    
    @IBAction func html(_ sender: UIButton) {
        extensionTextField.text = "html"
    }

    @IBAction func css(_ sender: UIButton) {
        extensionTextField.text = "css"
    }
    
    @IBAction func js(_ sender: UIButton) {
        extensionTextField.text = "js"
    }
    
    @IBAction func php(_ sender: UIButton) {
        extensionTextField.text = "php"
    }
    
    @IBAction func txt(_ sender: UIButton) {
        extensionTextField.text = "txt"
    }
    
}
