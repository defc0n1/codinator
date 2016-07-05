//
//  CSSTextView.swift
//  Codinator
//
//  Created by Vladimir Danila on 08/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class CSSTextView: CYRTextView {
    
    var defaultFont: UIFont = UserDefaults.standard().font(key: "Font: 0")! {
        didSet {
            tokens = highlightingTokens()
        }
    }
    
    var boldFont: UIFont = UserDefaults.standard().font(key: "Font: 1")! {
        didSet {
            tokens = highlightingTokens()
        }
    }
    
    var italicFont: UIFont = UserDefaults.standard().font(key: "Font: 2")! {
        didSet {
            tokens = highlightingTokens()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetUp()
    }
    
    
    func commonSetUp() {
        self.font = defaultFont
        self.textColor = UIColor.white()
        self.indicatorStyle = .white
        
        self.tokens = highlightingTokens()
    }
    
    func highlightingTokens() -> [CYRToken] {
        
        
        let commentAttributes = [
            NSForegroundColorAttributeName : SyntaxHighlighterDefaultColors.commentGreen,
        ]
        
        
        
        let tokens = [
        
            CYRToken(name: "property",
                expression: "(\\b|\\B)[\\w-]+(?=\\s*:)",
                attributes: HighlighterExtention.attributesForKey(.ReservedWords)
            ),
            
            CYRToken(name: "selectors",
                expression: "[^\\{\\}\\s][^\\{\\};]*?(?=\\s*\\{)",
                attributes: HighlighterExtention.attributesForKey(.Tag)
            ),
            
            CYRToken(name: "functions",
                expression: "[-a-z0-9]+(?=\\()",
                attributes: [
                    NSForegroundColorAttributeName : SyntaxHighlighterDefaultColors.darkGoldColor
            ]),
            
            
            CYRToken(name: "string",
                expression: "(\"|')(\\\\(?:\\r\\n|[\\w\\W])|(?!\\1)[^\\\\\\r\\n])*\\1",
                attributes: HighlighterExtention.attributesForKey(.String)
            ),
            
            
            CYRToken(name: "urls",
                expression: "url\\((?:([\"'])(\\\\(?:\\r\\n|[\\w\\W])|(?!\\1)[^\\\\\\r\\n])*\\1|.*?)\\)",
                attributes: [
                    NSForegroundColorAttributeName : SyntaxHighlighterDefaultColors.darkGoldColor
                ]
            ),
            
            
            CYRToken(name: "documentation_comment",
                expression: "\\/\\*[\\w\\W]*?\\*\\/",
                attributes: commentAttributes
            ),
            
            
            
            CYRToken(name: "comment",
                expression: "(^|[^\\\\:])\\/\\/.*",
                attributes: commentAttributes
            )
            
        ]
        
        return tokens
    }
}
