//
//  FilesTableViewControllerLongPress.swift
//  Codinator
//
//  Created by Vladimir Danila on 24/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension FilesTableViewController: UITableViewDataSourcePrefetching {
    
    // MARK: - Cell loading

    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = bgColorView
        
        let text = items[(indexPath as NSIndexPath).row].lastPathComponent
        if text != "" {
            cell.textLabel?.text = text
            

            let queue = DispatchQueue.global(qos: .userInitiated)
            queue.sync(execute: {
                
                // Check if image was already chached
                if let image = self.prefetchedImages[indexPath] {
                    if image != cell.imageView!.image {
                        
                        cell.imageView!.image = image
                    }
                }
                else {
                    if let url = self.projectManager?.inspectorURL.appendingPathComponent(text) {
                        var image = Thumbnail.sharedInstance.file(with: url)
                        
                        if image.size != CGSize(width: 128, height: 128) {
                            image = Thumbnail.sharedInstance.cropped(image: image, size: CGSize(width: 128, height: 128))!
                        }
                        
                        
                        if image != cell.imageView!.image {
                            cell.imageView!.image = image
                            self.prefetchedImages[indexPath] = image
                        }
                        
                    }
                }
                
            })
            
            
        }
        
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FilesTableViewController.tableViewCellWasLongPressed))
        cell.addGestureRecognizer(longPressGestureRecognizer)
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        
        // itterate through indexPaths
        for indexPath in indexPaths {
            
            // Check if image wasn't eventually already chached
            if prefetchedImages[indexPath] == nil {
                
                // Get text
                let text = items[(indexPath as NSIndexPath).row].lastPathComponent
                guard let url = self.projectManager?.inspectorURL.appendingPathComponent(text) else {
                        return
                }
                
                var image = Thumbnail.sharedInstance.file(with: url)
                
                if image.size != CGSize(width: 128, height: 128) {
                    image = Thumbnail.sharedInstance.cropped(image: image, size: CGSize(width: 128, height: 128))!
                }
                
                prefetchedImages[indexPath] = image
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
    
    
    // MARK: - Table View Selection
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedURL = inspectorURL?.appendingPathComponent(items[(indexPath as NSIndexPath).row].lastPathComponent) {
            var isDirectory : ObjCBool = ObjCBool(false)
            
            if (FileManager.default.fileExists(atPath: selectedURL.path, isDirectory: &isDirectory) && isDirectory.boolValue == true) {
                                
                projectManager.inspectorURL = selectedURL
                
                if let controller = storyboard?.instantiateViewController(withIdentifier: "filesTableView") as? FilesTableViewController {
                    controller.inspectorURL = selectedURL
                    
                    
                    count += 1
                    self.navigationController?.show(controller, sender: self)
                
                }
                
            } else {
                
                
                switch selectedURL.pathExtension {
                    
                case "png","img","jpg","jpeg", "gif", "PNG","IMG","JPG","JPEG", "GIF":
                    
                    projectManager.tmpFileURL = selectedURL
                    
                    let cell = tableView.cellForRow(at: indexPath)!
                    
                    
                    
                    let imageInfo = JTSImageInfo()
                    imageInfo.image = UIImage(contentsOfFile: selectedURL.path)
                    
                    imageInfo.referenceRect = cell.imageView!.frame
                    imageInfo.referenceView = cell.imageView?.superview
                    
                    let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: .image, backgroundStyle: .blurred)
                    
                    imageViewer?.show(from: self, transition: .fromOriginalPosition)
                    
                    
                case "zip":
                    let unzipStoryBoard = UIStoryboard(name: "UnZip", bundle: nil)
                    
                    let viewController = unzipStoryBoard.instantiateInitialViewController() as! UnArchivingViewController
                    viewController.modalPresentationStyle = .overFullScreen
                    
                    viewController.filePathToZipFile = selectedURL.path
                    
                    self.present(viewController, animated: true, completion: nil)
                    
                case "pdf":
                    projectManager.tmpFileURL = selectedURL
                    self.performSegue(withIdentifier: "run", sender: self)
                    
                    
                default:
                    
                    if let data = FileManager.default.contents(atPath: selectedURL.path) {
                        let contents = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                        
                        projectManager?.selectedFileURL = selectedURL
                        
                        getSplitView.showDetailViewController(getSplitView.editorView!, sender: self)
                        getSplitView.editorView!.text = contents as? String
                        getSplitView.webView!.loadFileURL(selectedURL, allowingReadAccessTo: projectManager!.projectURL())
                        getSplitView.assistantViewController?.setFilePathTo(projectManager)
                    }
                    else {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    
                }
                
            }
        }
    }
    
    

    
    func tableViewCellWasLongPressed(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: tableView)
        let position = CGRect(x: point.x, y: point.y, width: 20, height: 0)
        
        let indexPath = tableView.indexPathForRow(at: point)
        if sender.state == .began && indexPath != nil {
            projectManager.deleteURL = projectManager.inspectorURL.appendingPathComponent(items[(indexPath! as NSIndexPath).row].lastPathComponent)
            
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.delete()
            })
            
            
            let previewAction = UIAlertAction(title: "Preview", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "run", sender: self)
            })
            
            
            let printAction = UIAlertAction(title: "Print", style: .default, handler: { _ in
                self.peekPrint()
            })
            
            
            let moveAction = UIAlertAction(title: "Move file", style: .default, handler: { _ in
                self.move()
            })
            
            
            let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { _ in
                self.rename()
            })
            
            
            let shareAction = UIAlertAction(title: "Share", style: .default, handler: { _ in
                self.indexPath = indexPath
                self.share()
            })
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                
                if self.getSplitView.displayMode == .primaryHidden {
                    self.getSplitView.preferredDisplayMode = .primaryOverlay
                }

                
            })
            
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let pathExtension = self.projectManager.deleteURL!.pathExtension
            
            
            if pathExtension != "" {
                alertController.addAction(previewAction)
                alertController.addAction(printAction)
            }
            
            alertController.addAction(moveAction)
            alertController.addAction(renameAction)
            
            if pathExtension != "" {
                alertController.addAction(shareAction)
            }
            
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            alertController.popoverPresentationController?.sourceView = tableView
            alertController.popoverPresentationController?.sourceRect = position
            
            
            if getSplitView.displayMode != .primaryOverlay {
                self.present(alertController, animated: true, completion: nil)
            }
            else {

                alertController.title = projectManager.deleteURL!.lastPathComponent
                alertController.message = "What do you want to do with the file?"
                
                getSplitView.preferredDisplayMode = .primaryHidden
                getSplitView!.rootVC.present(alertController, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    
}
