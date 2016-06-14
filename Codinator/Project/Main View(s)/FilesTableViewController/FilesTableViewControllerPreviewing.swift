//
//  FilesTableViewControllerPreviewing.swift
//  Codinator
//
//  Created by Vladimir Danila on 25/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension FilesTableViewController: UIViewControllerPreviewingDelegate {
    
    // Peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
            
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else {
                return nil
        }
        

        let fileName = items[(indexPath as NSIndexPath).row].lastPathComponent!
        let path = try! inspectorURL!.appendingPathComponent(fileName)
        
        self.projectManager.deleteURL = path
        
        switch path.pathExtension! {
    
        case "png", "jpg", "jpeg", "bmp", "":
            
            guard let previewVC = storyboard?.instantiateViewController(withIdentifier: "imageViewPeek") as? PeekImageViewController,
            imageView = previewVC.view.subviews.first as? UIImageView else {
                return nil
            }
            
            imageView.image = cell.imageView?.image
            previewingContext.sourceRect = cell.frame
            
            self.indexPath = indexPath
            previewVC.delegate = self
            
            if path.pathExtension == "" {
                let imageViewSize = cell.imageView!.frame.size
                previewVC.preferredContentSize = CGSize(width: imageViewSize.width * 3, height: imageViewSize.height * 3)
                previewVC.isDir = true

            }
            
            return previewVC
            
            
        default:
            guard let previewVC = storyboard?.instantiateViewController(withIdentifier: "webViewPeek") as? PeekWebViewController else {
                return nil
            }
            previewVC.delegate = self
            previewVC.previewURL = path
            previewingContext.sourceRect = cell.frame
            
            return previewVC
        }
        
    }
    
    
    // Pop
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let path = self.projectManager.deleteURL
        
        switch path!.pathExtension! {
        case "png", "jpg", "jpeg", "bmp", "":
            break
            
            
        default:
            guard let webView = getSplitView.webView else {
                return
            }
            
            
            webView.loadFileURL(path!, allowingReadAccessTo: try! path!.deletingLastPathComponent())
            
            projectManager.selectedFileURL = path
            projectManager.deleteURL = nil
            
            if let data = FileManager.default().contents(atPath: path!.path!) {
                let contents = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                
                getSplitView.editorView!.text = contents as? String
                
                getSplitView.assistantViewController?.setFilePathTo(projectManager)
                
                _ = self.selectFileWithName(path!.lastPathComponent!)
                
            }
            
        }
        
        
    }
    
}
