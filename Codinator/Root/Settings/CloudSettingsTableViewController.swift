//
//  CloudSettingsTableViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 29/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class cloudHelper {
    class func cloudAvailable() -> Bool {
        if let _ = try! FileManager.default().urlForUbiquityContainerIdentifier(nil)?.appendingPathComponent("Documents") {
           return true
        }
        else {
            return false
        }
    }
}

class CloudSettingsTableViewController: UITableViewController {
    
    @IBOutlet var cells: [UITableViewCell]!

    
    @IBOutlet var useCloud: UISwitch!
    @IBOutlet var cloudAvailableLabel: UILabel!
    
    
    
    let kUseCloud = "CnCloud"
    let userDefauls = UserDefaults.standard()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        cells.forEach { $0.backgroundColor = tableView.backgroundColor }
        
        
        if let _ = try! FileManager.default().urlForUbiquityContainerIdentifier(nil)?.appendingPathComponent("Documents") {
            useCloud.isOn = !userDefauls.bool(forKey: kUseCloud)
            cloudAvailableLabel.text = ""
        }
        else {
            cloudAvailableLabel.text = "Please make sure iCloud is enabled in Settings."
            useCloud.isEnabled = false
        }
        
        
    }

    @IBAction func cloudSwitchChanged(_ sender: UISwitch) {
        userDefauls.set(!useCloud.isOn, forKey: kUseCloud)
        NotificationCenter.default().post(name: Notification.Name(rawValue: "reload"), object: nil)
    }
    
    
    @IBAction func doneDidPush(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    
    
}
