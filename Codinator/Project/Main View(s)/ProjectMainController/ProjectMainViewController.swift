//
//  ProjectMainViewController.swift
//  Codinator
//
//  Created by Lennart Kerkvliet on 27-03-16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit
import WebKit


class ProjectMainViewController: UIViewController, UISplitViewControllerDelegate {

    
    var path: String!
    
    // Assistant Grabber
    
    @IBOutlet weak var assistantGrabberConstraint: NSLayoutConstraint!
    @IBOutlet weak var assistantConstraint: NSLayoutConstraint!
    @IBOutlet weak var assistantGrabberView: UIView!
    @IBOutlet var assistantView: UIView!
    
    // WebView Grabber

    
    @IBOutlet var grabberConstraint: NSLayoutConstraint!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var grabberView: UIView!
    
    @IBOutlet var leftButton: UIBarButtonItem!
    @IBOutlet var bottomButton: UIBarButtonItem!
    @IBOutlet var rightButton: UIBarButtonItem!
    
    
    var webView: WKWebView?
    var getSplitView: ProjectSplitViewController! {
     
        get {
            return (self.childViewControllers.first as? ProjectSplitViewController)
        }
        
    }
    
    
    // Notifications 
    @IBOutlet weak var notificationsView: NotificationsView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        
        // WebView
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.applicationNameForUserAgent = "Codinator"
        if #available(iOS 10.0, *) { configuration.mediaTypesRequiringUserActionForPlayback = .all }
    
        
        webView = WKWebView(frame: bottomView.frame, configuration: configuration)
        webView?.allowsLinkPreview = true
        
        webView?.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(webView!)
        
        
        bottomView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .top, relatedBy: .equal, toItem: webView, attribute: .top, multiplier: 1.0, constant: 0.0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: webView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .left, relatedBy: .equal, toItem: webView, attribute: .left, multiplier: 1.0, constant: 0.0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .right, relatedBy: .equal, toItem: webView, attribute: .right, multiplier: 1.0, constant: 0.0))
        
        
        // webView
        getSplitView.webView = webView
        getSplitView.projectManager = Polaris(projectPath: path, currentView: nil, withWebServer: UserDefaults.standard().bool(forKey: "CnWebServer"), uploadServer: UserDefaults.standard().bool(forKey: "CnUploadServer"), andWebDavServer: UserDefaults.standard().bool(forKey: "CnWebDavServer"))
        getSplitView.mainViewController = self
        
        getSplitView.delegate = self

    }

    
    
    var notConfigured = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let projectName = getSplitView.projectManager.getSettingsData(forKey: "ProjectName") as! String
            self.navigationController?.navigationBar.topItem?.title = projectName
            getSplitView.rootVC = self
        
        
        
        self.getSplitView?.filesTableView?.viewDidAppear(true)
        
        getSplitView.undoButton = undoButton
        getSplitView.redoButton = redoButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white()]
    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        if getSplitView.filesTableView?.navigationController?.viewControllers.count == 1 {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            _ = getSplitView.filesTableView?.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func search(_ sender: UIBarButtonItem) {        
        if let _ = getSplitView.filesTableView!.navigationController?.viewControllers.last as? EditorViewController {
            getSplitView?.dealWithSearchBar()
        }
        else {
            
            if getSplitView.isCollapsed == false {
                getSplitView?.dealWithSearchBar()
            }
            else {
                Notifications.sharedInstance.alertWithMessage(nil, title: "Open a file", viewController: self)
            }
        }
    }
    
    
    var documentInteractionController: UIDocumentInteractionController?
    @IBAction func shareDidPush(_ sender: UIBarButtonItem) {
        
        // Create an NSURL for the file you want to send to another app
        if let fileUrl = getSplitView!.projectManager.selectedFileURL {
            
            // Create the interaction controller
            documentInteractionController = UIDocumentInteractionController(url: fileUrl)
            
            // Present the app picker display
            documentInteractionController!.presentOptionsMenu(from: sender, animated: true)
   
        }
        else {
            Notifications.sharedInstance.alertWithMessage(nil, title: "Select a file first", viewController: self)
        }
    }
    

    
    // MARK: - Trait Collection

    var isCompact: Bool {
        get {
            return self.getSplitView.view.traitCollection.horizontalSizeClass == .compact
        }
    }
    
    
    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!
    var removedOnce = false
    var firstStartHappened = false
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        
        if self.isCompact {
            var rightItems: [UIBarButtonItem] = self.navigationItem.rightBarButtonItems!
            
            if rightItems.count == 5 {
                rightItems.removeLast()
                
                self.navigationItem.rightBarButtonItems = rightItems
            }
        }
        else {
            var rightItems: [UIBarButtonItem] = self.navigationItem.rightBarButtonItems!
            
            if rightItems.count == 4 {
                rightItems.insert(leftButton, at: rightItems.count)
                self.navigationItem.rightBarButtonItems = rightItems
            }
        }
        
        
        
        if self.view.frame.width >= 480 {
            
            if removedOnce {
                self.navigationItem.leftBarButtonItems?.append(undoButton)
                self.navigationItem.leftBarButtonItems?.append(redoButton)
                removedOnce = false
            }
        }
        else {
            
            if removedOnce == false {
                self.navigationItem.leftBarButtonItems?.removeLast()
                self.navigationItem.leftBarButtonItems?.removeLast()
                removedOnce = true
            }
            
        }
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if size.width >= 480 {
            
            if removedOnce {
                self.navigationItem.leftBarButtonItems?.append(undoButton)
                self.navigationItem.leftBarButtonItems?.append(redoButton)
                removedOnce = false
            }
        }
        else {
            
            if removedOnce == false {
                self.navigationItem.leftBarButtonItems?.removeLast()
                self.navigationItem.leftBarButtonItems?.removeLast()
                removedOnce = true
            }
            
        }
        
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "assistantView" {
            self.getSplitView!.assistantViewController = segue.destinationViewController as? AssistantViewController
        }
        
        
    }
    



}
