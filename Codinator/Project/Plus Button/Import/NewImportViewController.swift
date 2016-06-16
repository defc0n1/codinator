//
//  ImportViewController.swift
//  VWAS-HTML
//
//  Created by Vladi Danila on 28/03/15.
//  Copyright (c) 2015 Vladimir Danila. All rights reserved.
//

import UIKit
import MessageUI

class NewImportViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIDocumentPickerDelegate,UITextFieldDelegate,NSURLConnectionDelegate{

    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    
    
    @IBOutlet var loadingView: UIVisualEffectView!
    
    
    var items: [String]!
    var webUploaderURL: String!
    var inspectorPath: String!

    weak var delegate: NewFilesDelegate?
    
    

    
    
    // MARK: - Shortcuts
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "W", modifierFlags: .command, action: #selector(NewImportViewController.close2), discoverabilityTitle: "Close Window")]
    }
    
    
    
    

    

    
    func close2(){
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func cancelDidPush(_ sender: AnyObject) {
        close2()
    }
    
    
    
    
    @IBAction func computerDidPush(_ sender: AnyObject) {
        
        
        if let webUploaderReference = webUploaderURL{
            let controller = UIAlertController(title: "Importing", message: "Visit this URL on another device (In the same network) to transfer your files:\n\n" + webUploaderReference, preferredStyle: .alert)
            controller.view.tintColor = UIColor.black()
            let reloadDataBase = UIAlertAction(title: "Reload File-Database ", style: .default) { (UIAlertAction) -> Void in
                
                self.dismiss(animated: true, completion: {
                    self.delegate?.reloadDataWithSelection(true)
                })
                
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            
            controller.addAction(reloadDataBase)
            controller.addAction(cancel)
            
            
            self.present(controller, animated: true, completion: nil)
        }
        else{
            
            let deviceName = UIDevice.current().model
            Notifications.sharedInstance.alertWithMessage("Please connect your " + deviceName + " to a Wi-Fi network and make sure web uploader is enabled in Settings.", title: "Error ❌", viewController: self)
            
        }
    
    
    }
    
    

    @IBAction func icloudDidPush(_ sender: AnyObject) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.vladidanila.VWAS-HTML.html","public.data","public.text","public.rtf","public.movie","public.audio","public.image","com.adobe.pdf","com.apple.keynote.key","com.microsoft.word.doc","com.microsoft.excel.xls","com.microsoft.powerpoint.ppt","public.svg-image","com.taptrix.inkpad","public.source-code","public.script","public.shell-script","public.executable"], in: UIDocumentPickerMode.import)
        
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    

    
    // MARK: image picker

    
    @IBAction func cameraDidPush(_ sender: AnyObject) {

        
        if (textField.text!.isEmpty){
            
            textField.alpha = 0
            label.alpha = 0
            textField.isHidden = false
            label.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.textField.alpha = 1
                self.label.alpha = 1
            })
            textField.becomeFirstResponder()
        }
        else{
         
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
        

            let popover : UIPopoverPresentationController = picker.popoverPresentationController!
            
            popover.sourceView = self.view
            popover.sourceRect = sender.frame
            
            
            present(picker, animated: true, completion: nil)
            


        }
    }
    
    
    // MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        // Load animation
        self.loadingView.effect = nil
        UIView.animate(withDuration: 0.4) {
            self.loadingView.alpha = 1.0
            self.loadingView.effect = UIBlurEffect(style: .dark)
        }
        
        
        
        DispatchQueue.global(attributes: .qosUserInitiated).async(execute: { 
          
            let pathToWriteFile = self.inspectorPath! + "/" + self.textField.text!
            var fileUrl = URL(fileURLWithPath: pathToWriteFile)
            
            if (fileUrl.lastPathComponent == ""){
                fileUrl = try! fileUrl.appendingPathExtension("png")
            }
            else{
                fileUrl = try! fileUrl.deletingPathExtension()
                fileUrl = try! fileUrl.appendingPathExtension("png")
            }
            
            
            
            let newFileName = NewFiles.availableName(fileUrl.lastPathComponent!, nameWithoutExtension: try! fileUrl.deletingPathExtension().lastPathComponent!, Extension: fileUrl.pathExtension!, items: self.items)
            fileUrl = try! fileUrl.deletingLastPathComponent().appendingPathComponent(newFileName)
            
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if let content = UIImagePNGRepresentation(image) {
                FileManager.default().createFile(atPath: (fileUrl.path)!, contents: content, attributes: nil)
            }
            
            
            
            DispatchQueue.main.async(execute: { 
                picker.dismiss(animated: true, completion: {
                    self.delegate?.reloadDataWithSelection(true)
                    self.dismiss(animated: true, completion: nil)
                })
            })
            
        })

    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    

    
    
    // MARK: textfield
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        if (textField.tag == 2){  //Image name
            
            cameraDidPush(cameraButton)
            textField.isHidden = true
        }
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.tag == 2){  //Image name
            
            cameraDidPush(cameraButton)
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    
    
    
    // MARK: cloud
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        if (controller.documentPickerMode == UIDocumentPickerMode.import){
            
            
            // Load animation
            self.loadingView.effect = nil
            UIView.animate(withDuration: 0.4) {
                self.loadingView.alpha = 1.0
                self.loadingView.effect = UIBlurEffect(style: .dark)
            }
            
            
            
            DispatchQueue.global(attributes: .qosUserInitiated).async(execute: {
            
            
            
            let name = url.lastPathComponent!
            let pathToWriteFile = self.inspectorPath! + "/" + name

            let content = try? Data(contentsOf: url)
            FileManager.default().createFile(atPath: pathToWriteFile, contents: content, attributes: nil)
            
                
                do {
                    try content?.write(to: URL(fileURLWithPath: self.inspectorPath!), options: [.dataWritingAtomic])
                } catch {}
                
                DispatchQueue.main.async(execute: { 
                    self.dismiss(animated: true, completion: {
                        self.delegate?.reloadDataWithSelection(true)
                    })
                })
                
            })
            
        }
        else {
            self.dismiss(animated: true, completion: {
                self.delegate?.reloadDataWithSelection(true)
            })
        }
    
    }
    

    // MARK: - Default
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
}


