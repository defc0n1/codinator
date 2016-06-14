//
//  ServersViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 20/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class ServersViewController: UIViewController {

    var projectManager: Polaris!
    
    @IBOutlet var webDavLabel: UILabel!
    @IBOutlet var webServerLabel: UILabel!
    @IBOutlet var webUploaderLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let wifiErrorMessage = "No Wi-Fi"
        let offErrorMessage = "Turned Off"
        let userDefaults = UserDefaults.standard()
        
        if let webDavIp = projectManager.webDavServerURL() {
            if webDavIp.isEmpty {
                
                if userDefaults.bool(forKey: "CnWebDavServer") {
                    webDavLabel.text = wifiErrorMessage
                }
                else {
                    webDavLabel.text = offErrorMessage;
                }
                
            }
            else {
                webDavLabel.text = webDavIp
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "/", with: "")
                
            }
        }
        
        if let webServerIp = projectManager.webServerURL() {
            if webServerIp.isEmpty {
                if userDefaults.bool(forKey: "CnWebServer") {
                    webServerLabel.text = wifiErrorMessage
                }
                else {
                    webServerLabel.text = offErrorMessage;
                }
            }
            else {
                webServerLabel.text = webServerIp
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "/", with: "")
            }
        }
        
        
        
        if let webUploaderIp = projectManager.webUploaderServerURL() {
            if webUploaderIp.isEmpty {
                if userDefaults.bool(forKey: "CnUploadServer") {
                    webServerLabel.text = wifiErrorMessage
                }
                else {
                    webServerLabel.text = offErrorMessage;
                }            }
            else {
                webUploaderLabel.text = webUploaderIp
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "/", with: "")
            }
        }
        
    
    }
    
    
    
    @IBAction func doneDidPush() {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
