//
//  imgSnippetViewController.swift
//  VWAS-HTML
//
//  Created by Vladimir on 29/03/15.
//  Copyright (c) 2015 Vladimir Danila. All rights reserved.
//

import UIKit


protocol SnippetsDelegate: class {
    func snippetWasCoppied(_ status: String)
    func colorDidChange(_ color: UIColor)
}


final class ImgSnippetsViewController: UIViewController,UITextFieldDelegate {
   
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var width: UITextField!
    @IBOutlet var height: UITextField!
   
    weak var delegate: SnippetsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.attributedPlaceholder = AttributedString(string:"link or path to projects", attributes:[NSForegroundColorAttributeName: UIColor.darkGray()])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func copyDidPush(_ sender: AnyObject) {
     
        var status = ""
        
        let text = textField.text
        let characterCount = text!.characters.count
        
        if characterCount != 0 {
            let image = (textField.text! as NSString).lastPathComponent
            let imageName = (image as NSString).deletingPathExtension
            let code = "<img src=\"\(text!)\" alt=\"\(imageName)\"  width=\"\(width.text!)\" height=\"\(height.text!)\">"
            status = "copied"
            
            let pasteboard = UIPasteboard.general()
            pasteboard.string = code
        }
        else{
            print("Error")
            status = "copiedError"
        }
        
        
        
        self.dismiss(animated: true, completion: {
            self.delegate?.snippetWasCoppied(status)
        })
        
    }
    
    @IBAction func cancelDidPush(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func viewDidTapped(_ sender: AnyObject) {
        textField.resignFirstResponder()
        width.resignFirstResponder()
        height.resignFirstResponder()
    }

    
}



final class LinkSnippetsViewController :UIViewController,UITextFieldDelegate{
    @IBOutlet var textField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    weak var delegate: SnippetsDelegate?


    @IBAction func cancelDidPush(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func generateDidPush(_ sender: AnyObject) {
    
        if nameTextField.text!.isEmpty {
            nameTextField.becomeFirstResponder()
        }
        else if textField.text!.isEmpty {
            textField.becomeFirstResponder()
        }
        else{
            let code = "<a href=\"\(textField.text!)\">\(nameTextField.text!)</a>"
            let pasteBoard = UIPasteboard.general()
            pasteBoard.string = code
            
            self.dismiss(animated: true, completion: {
                
                self.delegate?.snippetWasCoppied("copied")
            
            })
        }
    }
    
    

    func textFieldShouldReturn(_ textField2: UITextField) -> Bool {
       textField2.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField2: UITextField) {
        let placeHolder = textField2.placeholder
        print(placeHolder)
        
        if (placeHolder == "http link to subpage "){
            textField.text = "http://"
        }
    }
    
    @IBAction func viewDidTapped(_ sender: AnyObject) {
        textField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
    
}






final class ListSnippetsViewController :UIViewController{
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var enumNumberLabel: UILabel!
    
    weak var delegate: SnippetsDelegate?
    
    @IBAction func stepperDidPush(_ sender: AnyObject) {
        let integer = Int(stepper.value)
        enumNumberLabel.text = "\(integer)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let integer = Int(stepper.value)
        enumNumberLabel.text = "\(integer)"
    }
    
    @IBAction func cancelDidPush(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func generateDidPush(_ sender: AnyObject) {
        var  tags = "<ul> \n"
        
      
        for _ in 1...Int(stepper.value)
        {
            let middleTag = "   <li></li> \n"
            tags += middleTag
        }
        tags += "</ul> "
        
        let pasteBoard = UIPasteboard.general()
        pasteBoard.string = tags
        
        self.dismiss(animated: true, completion: {
            self.delegate?.snippetWasCoppied("copied")
        })
    }
    
    
    
}

