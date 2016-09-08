//
//  SettingsTableViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 25/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class SettingsTableViewController: UITableViewController, SKStoreProductViewControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var cells: [UITableViewCell]!
    
    
    let kLineNumber = "CnLineNumber"
    let kWebServer = "CnWebServer"
    let kWebDavServer = "CnWebDavServer"
    let kUploadServer = "CnUploadServer"
    
    @IBOutlet weak var showLineNumberSwitch: UISwitch!
    
    @IBOutlet var useWebDavServerSwitch: UISwitch!
    @IBOutlet weak var useWebServerSwitch: UISwitch!
    @IBOutlet weak var useUploadServerSwitch: UISwitch!
    
    let userDefauls = UserDefaults.standard

    
    
    @IBOutlet var extraCells: [UITableViewCell]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cells.forEach { $0.backgroundColor = tableView.backgroundColor }
        
        self.showLineNumberSwitch.isOn = userDefauls.bool(forKey: kLineNumber)
        
        self.useWebServerSwitch.isOn = userDefauls.bool(forKey: kWebServer);
        self.useWebDavServerSwitch.isOn = userDefauls.bool(forKey: kWebDavServer);
        self.useUploadServerSwitch.isOn = userDefauls.bool(forKey: kUploadServer);
       
        
        extraCells.forEach {
            $0.contentView.superview?.backgroundColor = tableView.backgroundColor
        }
        
    }

    //MARK: Switches Changed
    
    
    @IBAction func showLineNumberSwichChanged(_ sender: AnyObject) {
        userDefauls.set(self.showLineNumberSwitch.isOn, forKey: kLineNumber)
    }
    
    
    
    @IBAction func webDavSwichChanged(_ sender: AnyObject) {
        userDefauls.set(self.useWebDavServerSwitch.isOn, forKey: kWebDavServer)
    }
    
    
    @IBAction func webServerSwichChanged(_ sender: AnyObject) {
        userDefauls.set(self.useWebServerSwitch.isOn, forKey: kWebDavServer)
    }
    
    
    @IBAction func uploadServerSwichChanged(_ sender: AnyObject) {
        userDefauls.set(self.useUploadServerSwitch.isOn, forKey: kWebDavServer)
    }
    
    @IBAction func doneDidPush(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Did push cells
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 2 {
            tableView.deselectRow(at: indexPath, animated: true)

            switch (indexPath as NSIndexPath).row {
            case 0:
                if (MFMailComposeViewController.canSendMail()){
                    
                    let mailController = MFMailComposeViewController()
                    mailController.setSubject("Codinator Feedback")
                    mailController.setMessageBody("Hey Vladimir, \n", isHTML: false)
                    
                    mailController.setToRecipients(["vladidanila@icloud.com"])
                    
                    mailController.mailComposeDelegate = self
                    mailController.view.tintColor = self.view.tintColor
                    
                    self.present(mailController, animated: true, completion: nil)
                    
                }
                
        
            case 1:
                let storeProductViewController = SKStoreProductViewController()
                storeProductViewController.delegate = self
                let dict = [ SKStoreProductParameterITunesItemIdentifier : "1024671232"]
                storeProductViewController.loadProduct(withParameters: dict, completionBlock: nil)
                self.present(storeProductViewController, animated: true, completion: nil)
                
                
//            case 2:
//                if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)){
//                    
//                    let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//                    tweetSheet.setInitialText("#Codinator is amazing. Editing projects on the go has never been easier. You really should try it out!")
//                    tweetSheet.addURL(NSURL(string: "https://itunes.apple.com/us/app/codinator/id1024671232?ls=1&mt=8"))
//                    
//                    tweetSheet.view.tintColor = self.view.tintColor
//                    
//                    self.presentViewController(tweetSheet, animated: true, completion: nil)
//                    
//                    
//                }

            default:
                break
            }
            
            
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // MARK: - Delegates
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
