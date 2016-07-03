//
//  Notifications.swift
//  Codinator
//
//  Created by Vladimir Danila on 20/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

class Notifications: NSObject {
    static let sharedInstance = Notifications()
    
    var viewController: UIViewController!
    
    
    func alertWithMessage(_ message: String?, title: String?, viewController: UIViewController) {
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }

    func alertWithMessage(_ message: String?, title: String?, viewController: UIViewController, completion: (Void) -> Void) {
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in completion()})
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func alertWithMessage(_ message: String?, title: String?) {
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
