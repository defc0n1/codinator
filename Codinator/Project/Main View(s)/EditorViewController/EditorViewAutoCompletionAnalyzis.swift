//
//  EditorViewAutoCompletionAnalyzis.swift
//  Codinator
//
//  Created by Vladimir Danila on 6/18/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension EditorViewController {
   
    func jsVariableNames(text: String, completion: (varNames: [String]) -> Void){
        
        DispatchQueue.global(attributes: .qosUtility).async(execute: {
            
            let resource = text.components(separatedBy: "\n")
            
            // Get lines with 'var'
            let linesContainingVar = resource.filter { $0.contains("var") }.joined(separator: " ")
            
            // Get lines by word
            let split = linesContainingVar.characters.split(separator: " ").map(String.init)
            
            // Get index of 'var'
            let varsOffset = split.enumerated().filter { $0.element == "var" }.map { $0.offset }
            
            // Get variable names by obtaining word next to 'var's index
            let variableNames = varsOffset.map { offset -> String in
                if split.count > offset + 1 {
                    return split[offset + 1]
                }
                
                return ""
            }
            
            // Get rid of everything that is an empty string
            let optimizedNames = variableNames.filter { $0 != "" }
            
            
            completion(varNames: optimizedNames)

            
        })
        
    }
    
}
