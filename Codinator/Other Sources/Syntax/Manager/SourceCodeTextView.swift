//
//  SourceCodeTextView.swift
//  Codinator
//
//  Created by Vladimir Danila on 14/06/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class SourceCodeTextView: CYRTextView {

    var defaultFont: UIFont = UserDefaults.standard.font(key: "Font: 0")! {
        didSet {
            tokens = highlightingTokens()
        }
    }
    
    var boldFont: UIFont = UserDefaults.standard.font(key: "Font: 1")! {
        didSet {
            tokens = highlightingTokens()
        }
    }
    
    var italicFont: UIFont = UserDefaults.standard.font(key: "Font: 2")! {
        didSet {
            tokens = highlightingTokens()
        }
    }


    func highlightingTokens() -> [CYRToken] {
        return []
    }
}
