//
//  FilesTableViewActions.swift
//  Codinator
//
//  Created by Vladimir Danila on 25/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension FilesTableViewController: PeekProtocol {
    
    func peekPrint() {
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = "Print File"
        printInfo.orientation = .portrait
        printInfo.duplex = .longEdge
        
        let printController = UIPrintInteractionController.shared()
        printController.printInfo = printInfo
        
        let pathExtension = self.projectManager.deleteURL!.pathExtension!
        switch pathExtension {
            
        case "jpg", "jped", "png", "bmp":
            let image = UIImage(contentsOfFile: self.projectManager.deleteURL!.path!)
            let imageView = UIImageView(image: image)
            printController.printFormatter = imageView.viewPrintFormatter()
            
        default:
            
            if pathExtension != "" {
                let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                textView.text = try! String(contentsOf: projectManager.deleteURL!)
                printController.printFormatter = textView.viewPrintFormatter()
            }
            else {
                
                Notifications.sharedInstance.alertWithMessage(nil, title: "File type not supported")
                
            }
            
        }
        
        printController.present(animated: true, completionHandler: nil)
        
        if self.getSplitView.displayMode == .primaryHidden {
            self.getSplitView.preferredDisplayMode = .primaryOverlay
        }
    }
    
    func move() {
        self.performSegue(withIdentifier: "moveFile", sender: self)
        
        if self.getSplitView.displayMode == .primaryHidden {
            self.getSplitView.preferredDisplayMode = .primaryOverlay
        }
    }
    
    func rename() {
        let message = "Rename \(self.projectManager.deleteURL!.lastPathComponent)"
        
        let alert = UIAlertController(title: "Rename", message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = self.projectManager.deleteURL!.lastPathComponent!
            
            textField.keyboardAppearance = .dark
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        })
        
        
        let processAction = UIAlertAction(title: "Rename", style: .default, handler: { _ in
            
            let newName = alert.textFields?.first?.text
            let newURL = try! self.projectManager.deleteURL!.deletingLastPathComponent().appendingPathComponent(newName!)
            
            do {
                
                try FileManager.default().moveItem(at: self.projectManager.deleteURL!, to: newURL)
                
                self.reloadDataWithSelection(true)
                
                if self.getSplitView.displayMode == .primaryHidden {
                    self.getSplitView.preferredDisplayMode = .primaryOverlay
                }
                
                
            } catch let error as NSError {
                self.getSplitView.mainViewController.notificationsView.notify(with: error.localizedDescription)
            }
            
            
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(processAction)
        alert.addAction(cancelAction)
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func share() {
        // Create an NSURL for the file you want to send to another app
        let fileUrl = projectManager.deleteURL
        
        
        // Create the interaction controller
        self.documentInteractionController = UIDocumentInteractionController(url: fileUrl!)
        
        // Present the app picker display
        let cell = self.tableView.cellForRow(at: self.indexPath! as IndexPath)!
        
        if let cellImageView = cell.imageView, let _ = cell.imageView?.image {
            self.documentInteractionController?.presentOptionsMenu(from: cellImageView.frame, in: cellImageView.superview!, animated: true)
        }
        else {
            self.documentInteractionController?.presentOptionsMenu(from: cell.frame, in: tableView, animated: true)
        }
        
    }
    
    func delete() {
        let fileExists = FileManager.default().fileExists(atPath: self.projectManager.deleteURL!.path!)
        
        if fileExists {
            
            let alert = UIAlertController(title: "Are you sure you want to delete \(self.projectManager.deleteURL!.lastPathComponent!)?", message: nil, preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                
                do {
                    try FileManager.default().removeItem(at: self.projectManager.deleteURL!)
                    
                    self.reloadDataWithSelection(true)
                    
                    if self.getSplitView.displayMode == .primaryHidden {
                        self.getSplitView.preferredDisplayMode = .primaryOverlay
                    }
                    
                    
                } catch let error as NSError {
                    self.getSplitView.mainViewController.notificationsView.notify(with: error.localizedDescription)
                }
                
            })
            
            
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            getSplitView.mainViewController.notificationsView.notify(with: "There was an unexpected error")
        }
        
    }
    
}
