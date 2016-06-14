//
//  FileMoverViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 25/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class FileMoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var fileUrl: URL?
    
    var items: [URL]?
    
    let fileManager = FileManager.default()
    
    
    weak var delegate: NewFilesDelegate?
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    var backButtonEnabled: Bool {
        get {
            print(inspectorUrl?.path)
            return !(inspectorUrl!.path!.hasSuffix(".cnProj/Assets") || inspectorUrl!.path!.hasSuffix(".cnProj/Assets/"))
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            inspectorUrl = try! fileUrl!.deletingLastPathComponent()
            items = try fileManager.contentsOfDirectory(at: inspectorUrl!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            tableView.reloadData()
            
        } catch let error as NSError {
            Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Error", viewController: self)
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backButton.isEnabled = backButtonEnabled
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Buttons
    
    @IBAction func cancelDidPush() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moveFile() {
        
        let destinationUrl = try! inspectorUrl?.appendingPathComponent(fileUrl!.lastPathComponent!)
        if fileUrl?.absoluteString != destinationUrl?.absoluteString {
            
            do {
                try fileManager.moveItem(at: fileUrl!, to: destinationUrl!)
                self.dismiss(animated: true, completion: {
                    self.delegate?.reloadDataWithSelection(true)
                })
            } catch let error as NSError {
                Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Error", viewController: self)
            }
        
        }
        else {
            Notifications.sharedInstance.alertWithMessage(nil, title: "Locations are the same", viewController: self)
        }
    
    }
    
    @IBAction func backDidPush(_ sender: UIBarButtonItem) {
        inspectorUrl = try! inspectorUrl?.deletingLastPathComponent()
        
        do {
            items = try fileManager.contentsOfDirectory(at: inspectorUrl!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            tableView.reloadData()
            
        } catch let error as NSError {
            Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Error", viewController: self)
            self.dismiss(animated: true, completion: nil)
        }
        
        backButton.isEnabled = backButtonEnabled
    }
    

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    
    var inspectorUrl: URL?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.black()
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = tableView.backgroundColor
        
        
        if let text = items![(indexPath as NSIndexPath).row].lastPathComponent {
            cell.textLabel?.text = text
            cell.textLabel?.textColor = UIColor.white()
            
            if let path = try! inspectorUrl?.appendingPathComponent(text) {
                let manager = Thumbnail()
                cell.imageView?.image = manager.thumbnailForFile(atPath: path.path)
            }
        }
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUrl = try! inspectorUrl?.appendingPathComponent(items![(indexPath as NSIndexPath).row].lastPathComponent!, isDirectory: true)
        
        
        var isDirectory : ObjCBool = ObjCBool(false)
        
        if (FileManager.default().fileExists(atPath: selectedUrl!.path!, isDirectory: &isDirectory) && Bool(isDirectory) == true) {
            
            do {
                inspectorUrl = selectedUrl
                items = try fileManager.contentsOfDirectory(at: inspectorUrl!, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
                tableView.reloadData()
                
            } catch let error as NSError {
                Notifications.sharedInstance.alertWithMessage(error.localizedDescription, title: "Error", viewController: self)
                self.dismiss(animated: true, completion: nil)
            }
            
            backButton.isEnabled = backButtonEnabled
            
        }
        
    }
    
}
