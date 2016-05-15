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
import Twitter

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
    
    let userDefauls = NSUserDefaults.standardUserDefaults()

    
    
    @IBOutlet var extraCells: [UITableViewCell]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        cells.forEach { $0.backgroundColor = tableView.backgroundColor }
        
        self.showLineNumberSwitch.on = userDefauls.boolForKey(kLineNumber)
        
        self.useWebServerSwitch.on = userDefauls.boolForKey(kWebServer);
        self.useWebDavServerSwitch.on = userDefauls.boolForKey(kWebDavServer);
        self.useUploadServerSwitch.on = userDefauls.boolForKey(kUploadServer);
       
        
        extraCells.forEach {
            $0.contentView.superview?.backgroundColor = tableView.backgroundColor
        }
        
    }

    //MARK: Switches Changed
    
    
    @IBAction func showLineNumberSwichChanged(sender: AnyObject) {
        userDefauls.setBool(self.showLineNumberSwitch.on, forKey: kLineNumber)
        userDefauls.synchronize()
    }
    
    
    
    @IBAction func webDavSwichChanged(sender: AnyObject) {
        userDefauls.setBool(self.useWebDavServerSwitch.on, forKey: kWebDavServer)
        userDefauls.synchronize()
    }
    
    
    @IBAction func webServerSwichChanged(sender: AnyObject) {
        userDefauls.setBool(self.useWebServerSwitch.on, forKey: kWebDavServer)
        userDefauls.synchronize()
    }
    
    
    @IBAction func uploadServerSwichChanged(sender: AnyObject) {
        userDefauls.setBool(self.useUploadServerSwitch.on, forKey: kWebDavServer)
        userDefauls.synchronize()
    }
    
    @IBAction func doneDidPush(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    // MARK: - Did push cells
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

            switch indexPath.row {
            case 0:
                if (MFMailComposeViewController.canSendMail()){
                    
                    let mailController = MFMailComposeViewController()
                    mailController.setSubject("Codinator Feedback")
                    mailController.setMessageBody("Hey Vladimir, \n", isHTML: false)
                    
                    mailController.setToRecipients(["vladidanila@icloud.com"])
                    
                    mailController.mailComposeDelegate = self
                    mailController.view.tintColor = self.view.tintColor
                    
                    self.presentViewController(mailController, animated: true, completion: nil)
                    
                }
                
        
            case 1:
                let storeProductViewController = SKStoreProductViewController()
                storeProductViewController.delegate = self
                let dict = [ SKStoreProductParameterITunesItemIdentifier : "1024671232"]
                storeProductViewController.loadProductWithParameters(dict, completionBlock: nil)
                self.presentViewController(storeProductViewController, animated: true, completion: nil)
                
                
            case 2:
                if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)){
                    
                    let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    tweetSheet.setInitialText("#Codinator is amazing. Editing projects on the go has never been easier. You really should try it out!")
                    tweetSheet.addURL(NSURL(string: "https://itunes.apple.com/us/app/codinator/id1024671232?ls=1&mt=8"))
                    
                    tweetSheet.view.tintColor = self.view.tintColor
                    
                    self.presentViewController(tweetSheet, animated: true, completion: nil)
                    
                    
                }
                
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
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
