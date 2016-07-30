//
//  AssistantViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 22/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit


protocol AssistantViewControllerDelegate: class {
    
    /// Selects a file, retruns true if the files exists
    func selectFileWithName(_ name: String) -> Bool
}


final class AssistantViewController: UIViewController, SnippetsDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var fileNameTextField: UITextField?
    @IBOutlet var fileExtensionTextField: UITextField?
    
    @IBOutlet weak var pathLabel: UILabel!
    
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var modifiedLabel: UILabel!
    
    @IBOutlet weak var snippetsSuperView: UIVisualEffectView!
    
    @IBOutlet weak var snippetsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var snippetsSegmentControl: UISegmentedControl!
    
    
    weak var delegate: SnippetsDelegate?
    weak var renameDelegate: AssistantViewControllerDelegate?
    
    var projectManager: Polaris?
    var prevVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let polaris = projectManager {
            self.setFilePathTo(polaris)
            self.navigationItem.title = "Utilities"
        }
        else {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: snippetsViewHeightConstraint.constant, right: 0)
            
            scrollView.scrollIndicatorInsets = insets
            scrollView.contentInset = insets
        }
        
       
        fileNameTextField?.delegate = self
        fileExtensionTextField?.delegate = self

        snippetsSuperView.layer.cornerRadius = 5
        snippetsSuperView.layer.masksToBounds = true
        snippetsSuperView.layer.drawsAsynchronously = true
    }

    var fileUrl: URL?
    func setFilePathTo(_ projectManager: Polaris) {
        
        fileUrl = projectManager.selectedFileURL
        
        fileNameTextField!.text = try! fileUrl?.deletingPathExtension().lastPathComponent
        fileExtensionTextField!.text = fileUrl?.pathExtension
        
        pathLabel.text = projectManager.fakePathForFileSelectedFile()

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: projectManager.selectedFileURL!.path!)
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short


            let fileSize = (attributes[.size] as! Int)
            let createdDate = attributes[.creationDate] as! Date
            let modifiedDate = attributes[.modificationDate] as! Date

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let number = numberFormatter.string(from: fileSize as NSNumber)

            fileSizeLabel.text = "Size: \(number!) B"
            createdLabel.text = "Created: " + dateFormatter.string(from: createdDate)
            modifiedLabel.text = "Modified: " + dateFormatter.string(from: modifiedDate)
            
            
        } catch {
            
            fileSizeLabel.text = "Failed loading file size"
            createdLabel.text = "Failed loading created date"
            modifiedLabel.text = "Failed loading modified date"
            
            
        }
        
    }
    
    
    @IBOutlet weak var enumerationButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var colorPicker: UIButton!
    
    @IBAction func segmendDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            enumerationButton.isHidden = false
            imageButton.isHidden = false
            linkButton.isHidden = false
            
            colorPicker.isHidden = true
        }
        else {
            enumerationButton.isHidden = true
            imageButton.isHidden = true
            linkButton.isHidden = true
            
            colorPicker.isHidden = false
        }
    }
    
    
    
    // MARK: - Snippets delegate
    
    func snippetWasCoppied(_ status: String) {
        delegate?.snippetWasCoppied(status)
    }
    
    func colorDidChange(_ color: UIColor) {
        delegate?.colorDidChange(color)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TextFieldDelegate
    
    var previosText: String?
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if fileExtensionTextField!.text == "" && fileNameTextField!.text == "" {
            textField.resignFirstResponder()
        }
        else {
            previosText = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if previosText != textField.text {
            
            if fileNameTextField?.text == "" {
                Notifications.sharedInstance.alertWithMessage(nil, title: "Filename cant be empty", viewController: self)
                fileNameTextField?.becomeFirstResponder()
            }
            else {
                let fileManager = FileManager.default
                
                do {
                    try fileManager.moveItem(at: fileUrl!, to: fileUrl!.deletingLastPathComponent().appendingPathComponent(fileNameTextField!.text! + "." + fileExtensionTextField!.text!))
                    
                    _ = self.renameDelegate?.selectFileWithName(fileNameTextField!.text! + "." + fileExtensionTextField!.text!)
                    
                } catch let error as NSError {
                    Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Something went wrong!", viewController: self)
                }
            }
        }
        
        return false
        
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! UINavigationController
        vc.popoverPresentationController?.backgroundColor = vc.viewControllers.first?.view.backgroundColor


        switch segue.identifier! {
        case "img":
            (vc.viewControllers.first as! ImgSnippetsViewController).delegate = self
            
        case "link":
            (vc.viewControllers.first as! LinkSnippetsViewController).delegate = self
            
        case "list":
            (vc.viewControllers.first as! ListSnippetsViewController).delegate = self
            
        case "colorPicker":
            (vc.viewControllers.first as! ColorPickerViewController).delegate = self
            
        default:
            break
        }
    }
   
    // MARK: - Trait collection
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if size.width > 507 && projectManager != nil && prevVC != nil {
            _ = prevVC?.navigationController?.popViewController(animated: true)
        }
    
    }
    

}
