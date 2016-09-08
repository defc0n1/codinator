//
//  NewPlaygroundViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 22/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class NewPlaygroundViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var violett: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Save Violett color
        violett = nextButton.backgroundColor
        
        
        // Configure next Button
        nextButton.backgroundColor = UIColor.gray
        nextButton.isEnabled = false

        // Configure fileNameTextField
        fileNameTextField.attributedPlaceholder = NSAttributedString(string: "Playground name", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        
        fileNameTextField.layer.masksToBounds = true
        fileNameTextField.layer.borderColor = violett?.cgColor
        fileNameTextField.layer.borderWidth = 1.0
        fileNameTextField.layer.cornerRadius = 5
        
        fileNameTextField.addTarget(self, action: #selector(NewPlaygroundViewController.textFieldDidChange), for: UIControlEvents.editingChanged)

        
        self.nextButton.backgroundColor = UIColor.gray
        self.nextButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Buttons

    
    // Generate a new File
    @IBAction func nextDidPush(_ sender: AnyObject) {
        let document = PlaygroundFileCreator.generatePlaygroundFile(withName: fileNameTextField.text!)
        let url = document.fileURL

        document.save(to: url, for: .forOverwriting) { (success) in
            if success {
                self.dismiss(animated: true, completion: { 
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "createdProj"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: self, userInfo: nil)
                })
            }
            else {
                let alertController = UIAlertController(title: "Error", message: "Failed to create Playground", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    // Close View 
    @IBAction func closeDidPush(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    
    
    // MARK: - Textfield Delegate
    
    func textFieldDidChange() {
        if fileNameTextField.text?.isEmpty == true {
            fileNameTextField.layer.masksToBounds = true
            fileNameTextField.layer.borderColor = violett?.cgColor
            fileNameTextField.layer.borderWidth = 1
            fileNameTextField.layer.cornerRadius = 5
            
            // Textfield is emtpy so disable NextButton
            nextButton.isEnabled = false
            
            UIView.animate(withDuration: 0.2, animations: { 
                self.nextButton.backgroundColor = UIColor.gray
                self.nextButton.setTitleColor(UIColor.darkGray, for: UIControlState())

            })
        }
        else {
            
            // Textfield is not empty so enable NextButton
            nextButton.isEnabled = true
            
            UIView.animate(withDuration: 0.2, animations: {
                self.nextButton.backgroundColor = self.violett
                self.nextButton.setTitleColor(self.view.tintColor, for: UIControlState())
            })
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    

}
