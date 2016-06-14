//
//  SettingsGeneralViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 13/06/15.
//  Copyright © 2015 Vladimir Danila. All rights reserved.
//

import UIKit

class SettingsGeneralViewController: UIViewController {

    
    
    @IBOutlet weak var showLineNumberSwitch: UISwitch!
    
    @IBOutlet var useWebDavServerSwitch: UISwitch!
    @IBOutlet weak var useWebServerSwitch: UISwitch!
    @IBOutlet weak var useUploadServerSwitch: UISwitch!
    
    let userDefauls = UserDefaults.standard()
    
    let kLineNumber = "CnLineNumber"
    let kWebServer = "CnWebServer"
    let kWebDavServer = "CnWebDavServer"
    let kUploadServer = "CnUploadServer"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showLineNumberSwitch.isOn = userDefauls.bool(forKey: kLineNumber)
    
        self.useWebServerSwitch.isOn = userDefauls.bool(forKey: kWebServer);
        self.useWebDavServerSwitch.isOn = userDefauls.bool(forKey: kWebDavServer);
        self.useUploadServerSwitch.isOn = userDefauls.bool(forKey: kUploadServer);
    }

    
    
    
    //MARK: Switches Changed
    
    
    @IBAction func showLineNumberSwichChanged(_ sender: AnyObject) {        
        userDefauls.set(self.showLineNumberSwitch.isOn, forKey: kLineNumber)
        userDefauls.synchronize()
    }
    
    
    
    @IBAction func webDavSwichChanged(_ sender: AnyObject) {
        userDefauls.set(self.useWebDavServerSwitch.isOn, forKey: kWebDavServer)
        userDefauls.synchronize()
    }
    
    
    @IBAction func webServerSwichChanged(_ sender: AnyObject) {
        userDefauls.set(self.useWebServerSwitch.isOn, forKey: kWebDavServer)
        userDefauls.synchronize()
    }
    
    
    @IBAction func uploadServerSwichChanged(_ sender: AnyObject) {
        userDefauls.set(self.useUploadServerSwitch.isOn, forKey: kWebDavServer)
        userDefauls.synchronize()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
