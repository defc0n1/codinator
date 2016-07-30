//
//  WelcomeViewControllerAlertControllers.swift
//  Codinator
//
//  Created by Vladimir Danila on 19/07/2016.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension WelcomeViewController {

    /// Create an UIAlertController in Codinator design
    func alertController(title: String?, message: String?, preferredStyle: UIAlertControllerStyle) -> UIAlertController {

        let controller = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        let firstView = controller.view.subviews.first
        let nextView = firstView?.subviews.first
        nextView?.backgroundColor = self.collectionView.backgroundColor

        controller.view.tintColor = self.view.tintColor
        controller.popoverPresentationController?.backgroundColor = self.collectionView.backgroundColor

        return controller
    }

}
