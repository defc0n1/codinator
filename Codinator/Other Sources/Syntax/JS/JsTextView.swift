//
//  NeuronTextView.swift
//  Codinator
//
//  Created by Vladimir Danila on 28/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class JsTextView: CYRTextView {

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
        self.textColor = UIColor.white
        self.indicatorStyle = .white
        
        self.tokens = highlightingTokens()
    }
    
    func highlightingTokens() -> [CYRToken] {
        
        let regexAttributes = [
            NSForegroundColorAttributeName : SyntaxHighlighterDefaultColors.darkGoldColor
        ]
        
        let commentAttributes: [NSObject : AnyObject] = [
                NSForegroundColorAttributeName as NSObject : SyntaxHighlighterDefaultColors.commentGreen,
        ]
    
        
        
        let tokens = [

            CYRToken(name: "reserved_words",
                expression: "\\b(as|async|await|break|case|catch|class|const|continue|debugger|default|delete|do|else|enum|export|extends|finally|for|from|function|get|if|implements|import|in|instanceof|interface|let|new|null|of|package|private|protected|public|return|set|static|super|switch|this|throw|try|typeof|var|void|while|with|yield)\\b",
                attributes: HighlighterExtention.attributesForKey(.Tag)
            ),

            
            CYRToken(name: "string",
                expression: "\".*?(\"|$)|'.*?('|$)",
                attributes: HighlighterExtention.attributesForKey(.String)
            ),
            
            
            
            CYRToken(name: "regular_expression",
                expression: "/.*?(/|$)",
                attributes: regexAttributes
            ),
            
            CYRToken(name: "regular_expression_with_I",
                expression: "/.*?(/i|$)",
                attributes: regexAttributes
            ),
            
            CYRToken(name: "regular_expression_with_G",
                expression: "/.*?(/g|$)",
                attributes: regexAttributes
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
