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
    
    func displaySuccessMessage(_ message: String) {
        CSNotificationView.show(in: viewController, style: .success, message: message)
    }
    
    func displayErrorMessage(_ message: String) {
        CSNotificationView.show(in: viewController, style: .error, message: message)
    }
    
    func displayNeutralMessage(_ message: String) {
        CSNotificationView.show(in: viewController, tintColor: UIColor.white(), font: UIFont.systemFont(ofSize: 18), textAlignment: .center, image: nil, message: message, duration: 3.0)
    }
    
    
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
