//
//  QuickStartQuide.swift
//  VWAS-HTML
//
//  Created by Vladimir on 02/04/15.
//  Copyright (c) 2015 Vladimir Danila. All rights reserved.
//

import UIKit

class QuickStartQuide: UIViewController {

    
    
    @IBOutlet weak var okButton: UIButton?
    
    
    @IBAction func closeDidPush(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.masksToBounds = true
        self.view.layer.cornerRadius = 13
        self.view.layer.borderColor = UIColor(red: 55/255, green: 27/255, blue: 98/255, alpha: 1.0).cgColor
        self.view.layer.borderWidth = 3
        
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if (UIDevice.current.userInterfaceIdiom == .phone){
            return UIInterfaceOrientationMask.portrait
        }
        else{
            return UIInterfaceOrientationMask.all
        }
    
    }
    
    
}





class QuickStartQuidePlaygrounds: UIViewController {
    
    @IBInspectable var viewTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = viewTitle
    }
    
    @IBAction func closeDidPush(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}












