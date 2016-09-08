//
//  File.swift
//  Codinator
//
//  Created by Vladimir Danila on 05/07/2016.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension WelcomeViewController: UICollectionViewDataSourcePrefetching, UICollectionViewDataSource {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return projectsArray.count
            
        case 1:
            return playgroundsArray.count
            
        default:
            return 0
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var imagesDictionary = prefetchedImages as! [IndexPath : UIImage]
        
        
        // Get cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Document", for: indexPath) as! ProjectCollectionViewCell
        cell.imageView.image = nil
        
        
        // Switch between Projects urls and Playgrounds urls
        let url = indexPath.section == 0 ? projectsArray[indexPath.row] as! URL : playgroundsArray[indexPath.row] as! URL
        
        // Lod image
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            
            
            // Load image either from chache or from scratch
            let image = imagesDictionary[indexPath] != nil ? imagesDictionary[indexPath] : Thumbnail.sharedInstance.file(with: url, size: CGSize(width: 108, height: 144))
            
            // Is the image already chached?
            if imagesDictionary[indexPath] != nil {
                imagesDictionary[indexPath] = image
            }
            
            
            // Set the image
            DispatchQueue.main.async(execute: {
                cell.imageView.image = image
            })
            
            
        })
        
        // Download files from iCloud if they aren't downloaded yet.
        if indexPath.section == 2 || url.pathExtension == "icloud" {
            self.dealWithiCloudDownload(for: cell, for: indexPath, andFilePath: url.path)
        }
        
    
        // Make sure that there's no icloud file extension
        let cellText = url.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: ".icloud", with: "")
        cell.name.text = cellText
        
        

        
        // Create long press gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tableViewCellWasLongPressed(_:)))
        cell.addGestureRecognizer(longPressRecognizer)
        
        return cell
        
    }
    
    
    
    
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var imagesDictionary = prefetchedImages as! [IndexPath : UIImage]

        // Chache async
        DispatchQueue.global(qos: .default).async {
         
            // Itterate through indexPaths
            for indexPath in indexPaths {
                
                // Switch between Projects urls and Playgrounds urls
                let url = indexPath.section == 0 ? self.projectsArray[indexPath.row] as! URL : self.playgroundsArray[indexPath.row] as! URL
                
                // Make sure file is availabe localy
                if url.pathExtension != "icloud" {
                    
                    // Load image
                    let image = Thumbnail.sharedInstance.file(with: url, size: CGSize(width: 108, height: 144))
                    
                    // Check if image isnt the same in the dictionary
                    if imagesDictionary[indexPath] != image {
                        imagesDictionary[indexPath] = image
                    }
                    
                    
                }
                
                
            }

            
        }
        
    }
        

    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
    
}
