//
//  NeuronTextView.swift
//  Codinator
//
//  Created by Vladimir Danila on 28/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

final class NeuronTextView: SourceCodeTextView {

    override func commonSetUp() {
        self.font = defaultFont
        self.textColor = UIColor.white()
        self.indicatorStyle = .white
        
        self.tokens = highlightingTokens()
    }
    
    override func highlightingTokens() -> [CYRToken] {
        
        let tokens = [
            

            
            CYRToken(name: "reserved_words",
                expression: "\\b(algin|width|height|color|text|border|bgcolor|description|name|content|href|src|initialScale|charset|class|role|id|<!DOCTYPE html>|border)\\b",
                attributes:
                [
                    NSForegroundColorAttributeName : UserDefaults.standard.color(forKey: "Color: 5"),
                    NSFontAttributeName : self.defaultFont
                ]
            ),
            
            CYRToken(name: "Tags_neuron_Short",
                expression: "\\b(P|B|I|)\\b",
                attributes:
                [
                    NSForegroundColorAttributeName : UserDefaults.standard.color(forKey: "Color: 3"),
                    NSFontAttributeName : self.defaultFont
                ]
            ),
            
            
            CYRToken(name: "Tags_neuron_Long",
                expression: "\\b[A-Z][A-Z0-9]+\\b",
                attributes:
                [
                    NSForegroundColorAttributeName : UserDefaults.standard.color(forKey: "Color: 3"),
                    NSFontAttributeName : self.defaultFont
                ]
            ),
            
            CYRToken(name: "Tag",
                expression: HighlighterExtention.macroForKey(.Tag),
                attributes: HighlighterExtention.attributesForKey(.Tag)
            ),
            
            
            CYRToken(name: "string",
                expression: HighlighterExtention.macroForKey(.String),
                attributes: HighlighterExtention.attributesForKey(.String)
            )
        ]
        
        return tokens
    }

}
