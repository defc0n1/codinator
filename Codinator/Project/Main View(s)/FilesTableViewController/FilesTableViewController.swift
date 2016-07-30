//
//  FilesTableViewController.swift
//  Codinator
//
//  Created by Lennart Kerkvliet on 26-03-16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

final class FilesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewFilesDelegate, AssistantViewControllerDelegate{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var prefetchedImages = [IndexPath : UIImage]()
    
    
    var documentInteractionController: UIDocumentInteractionController?
    
    var items: [URL] = []
    
    
    var inspectorURL: URL?
    var projectManager: Polaris! {
        
        get {
            return getSplitView.projectManager
        }
        
    }
    
    
    var indexPath: IndexPath?
    
    var getSplitView: ProjectSplitViewController! {
        
        get {
            
            guard let splitView = self.splitViewController as? ProjectSplitViewController else {
                assertionFailure("SplitView is nil")
                return ProjectSplitViewController()
            }
            
            return splitView
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = inspectorURL { } else {
            inspectorURL = projectManager.inspectorURL
        }
        
        
        reloadDataWithSelection(true)
        
    
        let insets = UIEdgeInsetsMake(0, 0, toolBar.frame.height, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        tableView.prefetchDataSource = self

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.tableView)
        }
        
    }

    
    var hasntOpenIndexFileYet = true
    
    var count = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // Execute this only if FilesTableVC wasn't newly created
        if count > 0 {
            projectManager.inspectorURL = inspectorURL!
            
            if getSplitView.isCollapsed == false {
                _ = selectFileWithName("index.html")
            }
        }
                
        // Keyboard show/hide notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
            if hasntOpenIndexFileYet {
                // Find 'index.html' and save index of it in the array itself
                let items = self.items.enumerated().filter { ($0.element.absoluteString?.hasSuffix("index.html"))!}
                
                // if 'items' isn't empty sellect the corresponding cell
                if items.isEmpty != true {
                    
                    if self.getSplitView.view.traitCollection.horizontalSizeClass != .compact {
                        let indexPath = IndexPath(row: items.first!.offset, section: 0)
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                        tableView(tableView, didSelectRowAt: indexPath)
                    }
                    
                    // Load WebView
                    guard let webView = getSplitView.webView else {
                        return
                    }
                    
                    let url = try! projectManager.inspectorURL.appendingPathComponent(items.first!.element.lastPathComponent!)
                    
                    webView.loadFileURL(url, allowingReadAccessTo: try! url.deletingLastPathComponent())
                    
                    
                    hasntOpenIndexFileYet = false
                }
                else {
                    
                    guard let filePath = self.items.first?.lastPathComponent! else {
                        return
                    }
                    
                    
                    if self.items.count != 0 && filePath.hasSuffix("png") == false && filePath.hasSuffix("jpg") == false && self.items.first?.pathExtension != "" {
                        // No index file
                        
                        if getSplitView.isCollapsed == false {
                            
                            if self.getSplitView.view.traitCollection.horizontalSizeClass != .compact {
                                let indexPath = IndexPath(row: 0, section: 0)
                                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                                tableView(tableView, didSelectRowAt: indexPath)
                            }
                            
                            // Load WebView
                            guard let webView = getSplitView.webView else {
                                return
                            }
                            
                            guard let path = try! projectManager.inspectorURL.appendingPathComponent(filePath).path else {
                                return
                            }
                            
                            webView.loadFileURL( URL(fileURLWithPath: path, isDirectory: false), allowingReadAccessTo: URL(fileURLWithPath: path, isDirectory: true))
                        }
                        
                        hasntOpenIndexFileYet = false
                        
                    }
                    
                    
                }
        }

        
        getSplitView.assistantViewController?.renameDelegate = self
    
        
        NotificationCenter.default.addObserver(self, selector: #selector(FilesTableViewController._reloadData), name: "relaodData" as NSNotification.Name, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Assistant View
    
    
    // returns true if found
    func selectFileWithName(_ name: String) -> Bool {
        reloadDataWithSelection(false)
        
        // Find 'name' and save index of it in the array itself
        let items = self.items.enumerated().filter { ($0.element.absoluteString?.hasSuffix(name))!}
        
        // if 'items' isn't empty sellect the corresponding cell
        if items.isEmpty == false {
            let indexPath = IndexPath(row: items.first!.offset, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            tableView(tableView, didSelectRowAt: indexPath)
        }
        
        return items.isEmpty == false
        
    }
    
    

    // MARK: - Action Buttons
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        let Import = UIAlertAction(title: "Import", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "import", sender: self)
        }
        
        let newFile = UIAlertAction(title: "New File", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "newFile", sender: self)
        }
        
        let newSubpage = UIAlertAction(title: "New Subpage", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "newSubpage", sender: self)
        }
        
        let newDir = UIAlertAction(title: "New Directory", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "newDir", sender: self)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
            if self.getSplitView.displayMode == .primaryHidden {
                self.getSplitView.preferredDisplayMode = .primaryOverlay
            }
            
        })

        
        
        let popup = alertController(title: nil, message: nil, preferredStyle: .actionSheet)
        popup.addAction(Import)
        popup.addAction(newFile)
        popup.addAction(newSubpage)
        popup.addAction(newDir)
        popup.addAction(cancel)

        popup.popoverPresentationController?.barButtonItem = sender
        
        if getSplitView.displayMode != .primaryOverlay {
            self.present(popup, animated: true, completion: nil)
        }
        else {
            
            popup.title = "Product"
            
            getSplitView.preferredDisplayMode = .primaryHidden
            getSplitView!.rootVC.present(popup, animated: true, completion: nil)
        }
    }
    
    @IBAction func product(_ sender: UIBarButtonItem) {
        let archive = UIAlertAction(title: "Commit", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "archive", sender: self)
        }
        
        let export = UIAlertAction(title: "Export", style: .default) { (action : UIAlertAction) in
            Notifications.sharedInstance.alertWithMessage("Archive the Project first.\nAfterwards open up the History window and use the export manager.", title: "Export", viewController: self)
        }

        let history = UIAlertAction(title: "Commit History", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "history", sender: self)
        }
        
        let localServer = UIAlertAction(title: "Local Server", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "Pulse", sender: self)
        }
        
        let run = UIAlertAction(title: "Full Screen Preview", style: .default) { (action : UIAlertAction) in
            self.performSegue(withIdentifier: "run", sender: self)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

            if self.getSplitView.displayMode == .primaryHidden {
                self.getSplitView.preferredDisplayMode = .primaryOverlay
            }
    
        })
        
        
        let popup = alertController(title: nil, message: nil, preferredStyle: .actionSheet)
        popup.addAction(archive)
        popup.addAction(export)
        popup.addAction(localServer)
        popup.addAction(history)
        popup.addAction(run)
        popup.addAction(cancel)

        popup.popoverPresentationController?.barButtonItem = sender

        
        if getSplitView.displayMode != .primaryOverlay {
            self.present(popup, animated: true, completion: nil)
        }
        else {
            
            popup.title = "Product"
            
            getSplitView.preferredDisplayMode = .primaryHidden
            getSplitView!.rootVC.present(popup, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func navigateBackDidPush(_ sender: AnyObject) {
        if self.navigationController?.viewControllers.count != 1 {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    // MARK: - Keyboard show/hide
    
    let grabberViewHeight = CGFloat(10)
    var keyboardHeight: CGFloat = 0
    
    func keyboardWillShow(_ notification: Notification) {
    }
    
    func keyboardWillHide(_ notification: Notification) {
    }


    
    
    // MARK: - File Database

    func _reloadData() {
        
        self.items = projectManager!.contentsOfDirectory(atPath: inspectorURL!.path!).map { $0 as! URL}
        
            let ip = tableView.indexPathForSelectedRow
            
        if let indexPath = ip {
            tableView(tableView, didSelectRowAt: indexPath)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top )
        }
        
        tableView.reloadData()
        
    }
    
    
    func reloadDataWithSelection(_ selection: Bool) {
    
        self.items = projectManager!.contentsOfDirectory(atPath: inspectorURL!.path!).map { $0 as! URL}
        
        if selection == true {
            let ip = tableView.indexPathForSelectedRow
            
            if let indexPath = ip {
                tableView(tableView, didSelectRowAt: indexPath)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top )
            }
        }
     
        tableView.reloadData()
        
    }
    

    // MARK: - Storyboards
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
               
            case "newFile":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateFileViewController
                viewController.path = projectManager.inspectorURL.path
                viewController.items = self.items.map { $0.lastPathComponent! }
                viewController.projectManager = projectManager
                viewController.delegate = self
 
            case "newSubpage":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateSubpageViewController
                viewController.projectManager = projectManager
                viewController.delegate = self
                
            case "newDir":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateDirViewController
                viewController.projectManager = projectManager
                viewController.delegate = self
                
            case "import":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! NewImportViewController
               
                viewController.items = self.items.map{ $0.lastPathComponent! }
                viewController.webUploaderURL = projectManager.webUploaderServerURL()
                viewController.inspectorPath = projectManager.inspectorURL.path
                viewController.delegate = self
            
            case "run":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! AspectRatioViewController
                
                            
                
                // If path is not equal to "" path and if url is not nil
                let useDeleteURL = (projectManager.deleteURL?.path != URL(string: "")?.path) && (projectManager.deleteURL != nil)
                
                
            
                if useDeleteURL {
                    viewController.previewURL = projectManager.deleteURL!
                    projectManager.deleteURL = URL(string: "")
                }
                else {
                    if let tmpPath = projectManager.tmpFileURL {
                        if tmpPath.path!.isEmpty {
                            
                            if projectManager.inspectorURL.lastPathComponent != "index.html" {
                                viewController.previewURL = try! projectManager.inspectorURL.appendingPathComponent("index.html")
                            }
                            else {
                                viewController.previewURL = projectManager.inspectorURL
                            }
                            
                        }
                        else {
                            viewController.previewURL = projectManager.tmpFileURL
                            projectManager.tmpFileURL = nil
                        }
                    }
                    else {
                        if projectManager.inspectorURL.lastPathComponent != "index.html" {
                            viewController.previewURL = try! projectManager.inspectorURL.appendingPathComponent("index.html")
                        }
                        else {
                            viewController.previewURL = projectManager.inspectorURL
                        }
                    
                    }
                }
                
                
                
            case "archive":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ArchiveViewController
                viewController.projectManager = projectManager
                
            case "Pulse":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ServersViewController
                viewController.projectManager = projectManager
                
            case "history":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! HistoryViewController
                viewController.projectManager = projectManager
               
            case "moveFile":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! FileMoverViewController
                viewController.fileUrl = projectManager.deleteURL
                viewController.delegate = self
                
            default:
                break
            }
        
        }
        
    }


    // MARK: - UIAlertController modifications

    /// Create an UIAlertController in Codinator design
    private func alertController(title: String?, message: String?, preferredStyle: UIAlertControllerStyle) -> UIAlertController {

        let controller = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        let firstView = controller.view.subviews.first
        let nextView = firstView?.subviews.first
        nextView?.backgroundColor = tableView.backgroundColor

        controller.view.tintColor = self.view.tintColor
        controller.popoverPresentationController?.backgroundColor = tableView.backgroundColor

        return controller
    }

}
