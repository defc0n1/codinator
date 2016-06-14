//
//  UIViewExtension.swift
//  Codinator
//
//  Created by Vladimir Danila on 3/31/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": self]))

    }
}
