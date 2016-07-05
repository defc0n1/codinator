//
//  ColorPickerViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 23/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

protocol ColorProtocol: class {
    func colorDidChange(_ color: UIColor)
}

class ColorPickerViewController: UIViewController{

    
    
    @IBOutlet weak var colorPickerView: HRColorPickerView!
    weak var delegate: SnippetsDelegate?
    weak var colorDelegate: ColorProtocol?
    
    var color: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let predefinedColor = color {
            colorPickerView.color = predefinedColor
        }
        else {
            if let color = UserDefaults.standard.color(forKey: "colorPickerCn"){
                colorPickerView.color = color
            }
            else{
                colorPickerView.color = UIColor.purple()
            }
        }
        
    }

    
    @IBAction func doneDidPush() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.colorDidChange(colorPickerView.color)
        colorDelegate?.colorDidChange(colorPickerView.color)
    }
    
}

