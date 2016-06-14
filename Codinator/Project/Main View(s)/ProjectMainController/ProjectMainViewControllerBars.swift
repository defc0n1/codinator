//
//  ProjectMainViewControllerBars.swift
//  Codinator
//
//  Created by Vladimir Danila on 24/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension ProjectMainViewController {
    
    
    // MARK: - Panels
    
    
    @IBAction func left(_ sender: UIBarButtonItem) {
        if let splitViewController = getSplitView {
            
            if splitViewController.isCollapsed == false {
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState, animations: {
                    
                    
                    if splitViewController.preferredDisplayMode == .primaryHidden {
                        splitViewController.preferredDisplayMode = .allVisible
                    } else {
                        splitViewController.preferredDisplayMode = .primaryHidden
                    }
                    
                    }, completion: { (completion: Bool) in
                        
                })
                
            }
            else {
                _ = splitViewController.editorView?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func right(_ sender: UIBarButtonItem) {
        
        
        if getSplitView.isCollapsed == true {
            
            // If a file is selected
            if getSplitView.projectManager.selectedFileURL != nil {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "utilities") as! AssistantViewController
                viewController.projectManager = getSplitView.projectManager
                viewController.prevVC = getSplitView
                viewController.renameDelegate = getSplitView.filesTableView
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else {
                
                // No file selected 
                Notifications.sharedInstance.alertWithMessage(nil, title: "Select a file first", viewController: self)
            }
        }
        else if isCompact {
            
            // View hidden
            if assistantGrabberConstraint.constant <= 50 {
                assistantGrabberConstraint.constant = 216
                
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                }

            }
            
            // Not hidden
            else {
                assistantGrabberConstraint.constant = 0
                
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                }
            }
            
            
        }
        else {
            
            if assistantView.isHidden == true {
                self.assistantView.isHidden = false
                self.assistantGrabberView.isHidden = false
                
                assistantGrabberConstraint.isActive = true
                assistantConstraint.isActive = false
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { (completion: Bool) in
                        
                        // Completed Animation
                        
                })
            } else {
                assistantGrabberConstraint.isActive = false
                assistantConstraint.isActive = true
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { (completion: Bool) in
                        self.assistantGrabberView.isHidden = true
                        self.assistantView.isHidden = true
                        
                        
                })
            }
        }
        
    }
    
    
    @IBAction func bottom(_ sender: UIBarButtonItem) {
        
        if isCompact {
            
            if grabberConstraint.constant == 0 {
                grabberConstraint.constant = 200
                getSplitView?.webViewDidChange()
                
                
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                }
            }
            else {
                self.view.layoutIfNeeded()
                
                grabberConstraint.constant = 0
                getSplitView?.webViewDidChange()
                
                
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                }
            }
            
        }
        else {
            if bottomView.isHidden == true {
                self.bottomView.isHidden = false
                self.grabberView.isHidden = false
                
                grabberConstraint.isActive = true
                bottomConstraint.isActive = false
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { (completion: Bool) in
                        self.getSplitView?.webViewDidChange()
                })
            } else {
                grabberConstraint.isActive = false
                bottomConstraint.isActive = true
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { (completion: Bool) in
                        self.bottomView.isHidden = true
                        self.grabberView.isHidden = true
                        
                        self.getSplitView?.webViewDidChange()
                        
                })
            }
        }
    }

    
    
    
    
    func hidesRightPanel() {
        assistantGrabberConstraint.isActive = false
        assistantConstraint.isActive = true
        
        self.assistantGrabberView.isHidden = true
        self.assistantView.isHidden = true
        
        self.view.layoutIfNeeded()
        
        
    }
    
    func showRightPanel() {
        self.assistantView.isHidden = false
        self.assistantGrabberView.isHidden = false
        
        assistantGrabberConstraint.isActive = true
        assistantConstraint.isActive = false
        
        self.view.layoutIfNeeded()
    }
    
    
    
    // MARK: - Grabbers
    
    @IBAction func assistantGrabber(_ sender: UIPanGestureRecognizer) {
        
        assistantGrabberConstraint.constant = view.frame.width - sender.location(in: view).x
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func grabber(_ sender: UIPanGestureRecognizer) {
        getSplitView?.webViewDidChange()
        
        grabberConstraint.constant = view.frame.height - sender.location(in: view).y
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    
    
}
