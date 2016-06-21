//
//  ContributeViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 2/22/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit
import SafariServices

class ContributeViewController: UIViewController {
    
    @IBOutlet weak var gitHubButton: UIButton!
    @IBOutlet weak var slackButton: UIButton!
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func contributeOnGitHubDidPush(_ sender: AnyObject) {
      
        if #available(iOS 10.0, *) {
            UIApplication.shared().open(
                URL(string: "https://github.com/VWAS/Codinator")!
                , options: [:], completionHandler: nil
            )
        } else {
            UIApplication.shared().openURL(URL(string: "https://github.com/VWAS/Codinator")!)
        }
        
    }
    
    
    @IBAction func joinUsOnSlackDidPush(_ sender: AnyObject) {
        let sfController = SFSafariViewController(url:
            URL(string: "https://vwas-slack.herokuapp.com")!
        )
        
        sfController.modalPresentationStyle = .pageSheet
        present(sfController, animated: true, completion: nil)
    }
    
}
