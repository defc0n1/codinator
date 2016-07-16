//
//  NotificationsView.swift
//  Codinator
//
//  Created by Vladimir Danila on 6/20/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

final class NotificationsView: UIVisualEffectView {

    @IBOutlet var textLabel: UILabel!
    
    func notify(with text: String, duration: TimeInterval = 3) {
        
        textLabel.text = " \(text) "
        
        let hex = UIPasteboard.general().string
        let color = UIColor(hexString: hex)
        
        textLabel.textColor = color
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
        
        self.perform(#selector(NotificationsView.hide), with: self, afterDelay: duration)
        
    }
    
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }

}
