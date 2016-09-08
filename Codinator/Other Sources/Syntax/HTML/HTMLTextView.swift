//
//  HTMLTextView.swift
//  Codinator
//
//  Created by Vladimir Danila on 28/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit


final class HTMLTextView: SourceCodeTextView {


    override func commonSetUp() {
        self.font = defaultFont
        self.textColor = UIColor.white
        self.keyboardAppearance = .dark
        
        self.indicatorStyle = .white
        self.tokens = highlightingTokens()
    }
    
    override func highlightingTokens() -> [CYRToken] {
        
        let tokens = [
            
            CYRToken(name: "Tag",
                expression: HighlighterExtention.macroForKey(.Tag),
                attributes: HighlighterExtention.attributesForKey(.Tag)
            ),
            
            
            CYRToken(name: "square_brackets",
                expression: HighlighterExtention.macroForKey(.SquareBrackets),
                attributes: HighlighterExtention.attributesForKey(.SquareBrackets)
            ),
            
            
            CYRToken(name: "reserved_words",
                expression: HighlighterExtention.macroForKey(.ReservedWords),
                attributes: HighlighterExtention.attributesForKey(.ReservedWords)
            ),
            
            
            CYRToken(name: "string",
                expression: HighlighterExtention.macroForKey(.String),
                attributes: HighlighterExtention.attributesForKey(.String)
            ),
            
            CYRToken(name: "comment",
                expression: "<!--.*?(--!>|$)",
                attributes:
                [
                    NSForegroundColorAttributeName : SyntaxHighlighterDefaultColors.commentGreen
                ]
            )
            
        ]
        
        return tokens
    }
    

}
