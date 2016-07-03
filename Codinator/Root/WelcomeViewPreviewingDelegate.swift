//
//  WelcomeViewPreviewingDelegate.swift
//  Codinator
//
//  Created by Vladimir Danila on 25/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension WelcomeViewController: UIViewControllerPreviewingDelegate, PeekShortProtocol {
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = self.collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath) else {
                return nil
        }
        
        
        if (indexPath as NSIndexPath).section != 0 {
            return nil
        }
    
        let fileName: NSString = projectsArray[(indexPath as NSIndexPath).row].lastPathComponent!
        
        let root: NSString = AppDelegate.storageURL.path!
        let projectsRootDirPath: NSString = root.appendingPathComponent("Projects")
        let projectPath = projectsRootDirPath.appendingPathComponent(fileName as String)

        
        if fileName.pathExtension != ".zip" {
            let path = projectPath + "/Assets/index.html"
            
            guard let previewVC = storyboard?.instantiateViewController(withIdentifier: "webViewPeek") as? PeekWebViewController else {
                return nil
            }
            
            //        previewVC.delegate = self
            previewVC.isProjects = true
            previewVC.previewURL = URL(fileURLWithPath: path)
            previewingContext.sourceRect = cell.frame
            
            
            previewVC.projectsDelegate = self
            
            
            self.forceTouchPath = projectPath
            
            return previewVC
        }
        else {
            return nil
        }
    }
    
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
     
        if forceTouchPath.characters.count > 5 {
            
            self.document = CodinatorDocument(fileURL: URL(fileURLWithPath: forceTouchPath))
            document.open { sucess in
                
                if sucess {
                    self.projectIsOpened = true
                    
                    self.projectsPath = self.forceTouchPath
                    self.forceTouchPath = ""
                    
                    self.performSegue(withIdentifier: "projectPop", sender: nil)
                }
                else {
                    Notifications.sharedInstance.alertWithMessage("Failed opening the project.", title: "Error", viewController: self)
                }
                
            }
            
        }
    }
    
    
    // MARK: - Actions
    
    func rename() {
        let message = "Rename \(((forceTouchPath as NSString).lastPathComponent as NSString).deletingPathExtension)"
        
        let alertController = UIAlertController(title: "Rename", message: message, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Projects new name"
            textField.keyboardAppearance = .dark
            textField.tintColor = self.view.tintColor
        }
        
        let processRenaming = UIAlertAction(title: "Rename", style: .default) { _ in
            let newName = alertController.textFields![0].text! + ".cnProj"
            let newPath = (self.forceTouchPath as NSString).deletingLastPathComponent + newName
            
            let polaris = Polaris(projectPath: self.forceTouchPath!, currentView: nil, withWebServer: false, uploadServer: false, andWebDavServer: false)
            polaris.updateSettingsValue(forKey: "ProjectName", withValue: (newName as NSString).deletingPathExtension)
            
            do {
                try FileManager.default().moveItem(atPath: self.forceTouchPath, toPath: newPath)
                self.reloadData()
                
            } catch let error as NSError {
                Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Something went wrong", viewController: self)
            }
            
            
        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(processRenaming)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func delete() {
        
        do {
            try FileManager.default().removeItem(atPath: self.forceTouchPath)
            forceTouchPath = ""
            self.reloadData()
        } catch let error as NSError{
            Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Someting went wrong", viewController: self)
        }
        
    }
    
    
}
