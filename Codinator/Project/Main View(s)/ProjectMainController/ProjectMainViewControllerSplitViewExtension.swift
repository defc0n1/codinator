//
//  ProjectMainViewControllerSplitViewExtension.swift
//  Codinator
//
//  Created by Vladimir Danila on 14/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension ProjectMainViewController {
    
    @objc(splitViewController:collapseSecondaryViewController:ontoPrimaryViewController:) func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}
