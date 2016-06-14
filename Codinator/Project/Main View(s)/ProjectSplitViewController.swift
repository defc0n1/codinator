//
//  ProjectSplitViewController.swift
//  Codinator
//
//  Created by Lennart Kerkvliet on 26-03-16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

protocol ProjectSplitViewControllerDelegate {
    func webViewSizeDidChange()
    func searchBarAppeared()
    func searchBarDisAppeard()
}

class ProjectSplitViewController: UISplitViewController{

    var rootVC: ProjectMainViewController!
    
    
    var webView: WKWebView?
    var projectManager : Polaris!
    
    var redoButton: UIBarButtonItem!
    var undoButton: UIBarButtonItem!

    var splitViewDelegate: ProjectSplitViewControllerDelegate?

    
    weak var assistantViewController: AssistantViewController?
    
    
    var filesTableView: FilesTableViewController? {
        get {
            
            guard let filesTableNavController = self.viewControllers.first as? UINavigationController else {
                assertionFailure("Empty FilesTable Nav Controller")
                return nil
            }
            
            if let filesTableVC = filesTableNavController.viewControllers.last as? FilesTableViewController {
                return filesTableVC
            }
            else {
                guard let filesTableVC = filesTableNavController.viewControllers[viewControllers.count - 1] as? FilesTableViewController else {
                    assertionFailure("Empty FilesTable Nav Controller")
                    return nil
                }
                
                return filesTableVC
            }
            
        }
    }
    
    private var eView: EditorViewController!
    var editorView: EditorViewController? {
        get {
            
            
            if eView == nil {
                if let editorVC = self.viewControllers.last as? EditorViewController {
                    eView = editorVC
                    return eView
                }
                else {
                    eView = self.storyboard?.instantiateViewController(withIdentifier: "editorViewController") as? EditorViewController
                    return eView
                }
            }
            else {
                return eView
            }
            
        }
    }
    
    var webViewOnScreen: Bool {
        get {
            return isVisible(webView!)
        }
    }
    
    var mainViewController: ProjectMainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.minimumPrimaryColumnWidth = 200
        self.maximumPrimaryColumnWidth = 200
        self.preferredPrimaryColumnWidthFraction = 0.25
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        editorView!.splitViewFailreference = self
        editorView!.polarisFailreference = projectManager
    }
    
    // MARK: - Searchbar
    
    var searchBarVisible = false
    func dealWithSearchBar() {
        switch searchBarVisible {
        case true:
            searchBarDissappeared()
            
        case false:
            searchBarAppeared()
        }

    }
    
    func searchBarAppeared() {
        searchBarVisible = true
        splitViewDelegate?.searchBarAppeared()
    }
    
    func searchBarDissappeared() {
        searchBarVisible = false
        splitViewDelegate?.searchBarDisAppeard()
    }
    
    
    // MARK: - Custom API
    
    private func isVisible(_ view: UIView) -> Bool {
        func isVisible(_ view: UIView, inView: UIView?) -> Bool {
            guard let inView = inView else { return true }
            let viewFrame = inView.convert(view.bounds, from: view)
            if viewFrame.intersects(inView.bounds) {
                return isVisible(view, inView: inView.superview)
            }
            return false
        }
        return isVisible(view, inView: view.superview)
    }
    
    func webViewDidChange() {
        splitViewDelegate?.webViewSizeDidChange()
    }
    
    

    
    
}
