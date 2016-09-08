//
//  EngineViewControllerColorPicker.swift
//  Codinator
//
//  Created by Vladimir Danila on 26/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension EngineViewController: ColorProtocol {
 
    func colorDidChange(_ color: UIColor) {
        changeColorButton.tintColor = color
        UserDefaults.standard.setColor(color, forKey: "Color: \(selectedType)");
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "colorPicker" {
            let destViewController = segue.destination as! ColorPickerViewController
            destViewController.colorDelegate = self
            destViewController.color = changeColorButton.tintColor
            destViewController.navigationItem.title = "Color Picker"
        }
    }
    
}
