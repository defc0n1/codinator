//
//  ExportViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 24/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController, SSZipArchiveDelegate, UIDocumentInteractionControllerDelegate {

    var path: String?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var preparingFilesLabel: UILabel!
    
    @IBOutlet weak var chooseHowToSendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createZipArchive()
    }
    
    
    // MARK: - Zipping
    
    
    func createZipArchive() {
    
        let zipTmpPath = NSHomeDirectory() + "/Documents/Temp.zip"
        SSZipArchive.createZipFile(atPath: zipTmpPath, withContentsOfDirectory: path, delegate: self)
        
        
    }
    
    
    var documentInteractionController: UIDocumentInteractionController?
    func zipArchiveDidZippedArchive(toPath path: String!) {

        UIView.animate(withDuration: 0.4, animations: {
            self.preparingFilesLabel.isHidden = true
            self.activityIndicator.isHidden = true
            }) { bool in
            self.chooseHowToSendButton.isHidden = false
        }
        
        let url = URL(fileURLWithPath: path, isDirectory: false)
     
        // Create the interaction controller
        documentInteractionController = UIDocumentInteractionController(url: url)

        documentInteractionController?.delegate = self
        
        documentInteractionController?.presentOpenInMenu(from: chooseHowToSendButton.frame, in: self.view, animated: true)
        
    }
    
    @IBAction func shareDidPush(_ sender: UIButton) {
        
        let zipTmpPath = NSHomeDirectory() + "/Documents/Temp.zip"
        let url = URL(fileURLWithPath: zipTmpPath, isDirectory: false)
        
        // Create the interaction controller
        documentInteractionController = UIDocumentInteractionController(url: url)
        
        documentInteractionController?.delegate = self
        
        documentInteractionController?.presentOpenInMenu(from: sender.frame, in: self.view, animated: true)
    
    }
    
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    

    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func cancelDidPush(_ sender: AnyObject) {
    
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    

}
