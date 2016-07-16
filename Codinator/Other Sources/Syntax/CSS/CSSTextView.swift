//
//  CSSTextView.swift
//  Codinator
//
//  Created by Vladimir Danila on 08/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

final class CSSTextView: SourceCodeTextView {
    
   override func commonSetUp() {
        self.font = defaultFont
        self.textColor = UIColor.white()
        self.indicatorStyle = .white
        
        self.tokens = highlightingTokens()
    }
    
    override func highlightingTokens() -> [CYRToken] {
        
        
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
