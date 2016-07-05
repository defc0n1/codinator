//
//  HighlighterExtention.swift
//  Codinator
//
//  Created by Vladimir Danila on 28/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

class HighlighterExtention {
    
    class func attributesForKey(_ key: HighlightingDictionaryKey) -> [NSObject:AnyObject] {
        guard let attriutes = UserDefaults.standard.dic(forKey: key.rawValue) else {
            return [:]
        }
        
        return attriutes
    }
    
    class func macroForKey(_ key: HighlightingMacroKey) -> String {
        guard let macro = UserDefaults.standard.string(forKey: key.rawValue) else {
            return ""
        }
        
        return macro
    }
}
