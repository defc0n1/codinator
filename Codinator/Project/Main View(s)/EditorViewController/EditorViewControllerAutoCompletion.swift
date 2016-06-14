//
//  EditorViewControllerAutoCompletion.swift
//  Codinator
//
//  Created by Vladimir Danila on 24/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension EditorViewController: WUTextSuggestionDisplayControllerDataSource {
    
    
    func textSuggestionDisplayController(_ textSuggestionDisplayController: WUTextSuggestionDisplayController!, suggestionDisplayItemsFor suggestionType: WUTextSuggestionType, query suggestionQuery: String!) -> [AnyObject]! {
        if suggestionType == .tag {
            var suggestionDisplayItems : [WUTextSuggestionDisplayItem] = []
            for name in self.filteredNamesUsingQuery(suggestionQuery) {
                let item = WUTextSuggestionDisplayItem(title: name)
                suggestionDisplayItems.append(item!)
            }
            return suggestionDisplayItems
        }
        
        return nil;
    }
    
    func filteredNamesUsingQuery(_ query : String) -> [String] {
//         let filteredNames = self.names().filtered(using: Predicate(block: { (evaluatedObject : AnyObject, bindings: [String : AnyObject]?) -> Bool in
//            if let evaluatedObject = evaluatedObject as? String {
//                if evaluatedObject.lowercased().hasPrefix(query.lowercased()) {
//                    return true
//                }
//            }
//            
//            return false
//        })) as? [String] {
//            return filteredNames
//        }
//        
        return []
    }
    
    func names() -> NSArray {
        return ["h1>","/h1>","h2>","/h2>","h3>","/h3>","h4>","h5>","h6>","head>","body>","/body>","!Doctype html>","center>","img src=","a href=","font ","meta","table border=","tr>","td>","div>","div class=","style>","title>","li>","em>","p>","section class=","header>","footer>","ul>","del>","em>","sub>","sup>","var>","cite>","dfn>","big>","small>","strong>","code>","frameset","blackquote>","br>"]
    }
    
    func range() {
        
        guard let rangeString = UserDefaults.standard().string(forKey: "range") else {
            return
        }
        
        
        
        // Get string nearby the typing area
        
        var location: Int {
            let locationMinus10 = htmlTextView.selectedRange.location - 10
            if  htmlTextView.selectedRange.location - 10 > 0 {
                return locationMinus10
            }
            else {
                return htmlTextView.selectedRange.location - (locationMinus10 + 10)
            }
        }
        
        var length: Int {
            let maxLength = htmlTextView.text.characters.count - location - 10
            if maxLength >= 10 {
                return 10
            }
            else {
                return maxLength
            }
        }
        
        
        let stringFromRange = (htmlTextView.text as NSString).substring( with: NSRange(location: location, length: 10))
        
        // Find where the tag starts
        var findTag = stringFromRange.characters.enumerated().filter { $0.element == "<"}.last?.offset
        var findCloseBracket = stringFromRange.characters.enumerated().filter { $0.element == "/"}.last?.offset
    
        
        if findTag == nil {
            findTag = 0
        }
        
        if findCloseBracket == nil {
            findCloseBracket = 0
        }
        
        
        // Try to find the distance between the cursor and the beginning of the tag | close character (/). Since we don't want to delete the tag we do +1
        let itemsToDeleteTillTag = stringFromRange.characters.count - findTag! - 1
        let itemsToDeleteTillCloseTag = stringFromRange.characters.count - findCloseBracket! - 1
        
        // Delete the charachters that are after the tag
        let needsOpenAndCloseTag = findTag > findCloseBracket
        
        if needsOpenAndCloseTag {
            for _ in 1...itemsToDeleteTillTag {
                htmlTextView.deleteBackward()
            }
        }
        else {
            for _ in 1...itemsToDeleteTillCloseTag {
                htmlTextView.deleteBackward()
            }
        }

        
        
        
        // Complete the tag
        
        
        
        var checkString : String {
            if rangeString.characters.last == " " {
                return rangeString.substring(to: rangeString.characters.index(before: rangeString.endIndex))
            }
            else {
                return rangeString
            }
        }
        
        
        // Check if tag needs closing tag or not and insert the tag
        switch checkString {
        case "h1>", "h2>", "h3>",  "h4>", "h5>", "h6>", "head>", "body>", "!Documentype html>", "center>", "tr>", "title>", "li>", "section>", "header>", "footer>", "ul>", "del>", "em>", "sub>", "sup>", "var>", "small>", "strong>", "code>", "blackquote>", "p>", "big>","h1> ", "h2> ", "h3> ",  "h4>", "h5> ", "h6> ", "head> ", "body> ", "!Documentype html> ", "center> ", "tr> ", "title> ", "li> ", "section> ", "header> ", "footer> ", "ul> ", "del> ", "em> ", "sub> ", "sup> ", "var> ", "small> ", "strong> ", "code> ", "blackquote> ", "p> ", "big> ":
            
            let br = needsOpenAndCloseTag ? "</\(checkString)" : ""
            
            htmlTextView.insertText(checkString + br)
            
            // Move cursor back +1 since count starts with 0
            self.moveCursorBy(br.characters.count, diretion: .back)
            
            
        default:
            let br = checkString
            htmlTextView.insertText(br)
            
        }
        
        
        
    }
    
    enum MoveCursorDirection {
        case back
        case forward
    }
    
    func moveCursorBy(_ number: Int, diretion: MoveCursorDirection) {
        let range = htmlTextView.selectedRange
        
        switch diretion {
        case .back:
            htmlTextView.selectedRange = NSMakeRange(range.location - number, 0)
            
        case .forward:
            htmlTextView.selectedRange = NSMakeRange(range.location + number, 0)
        }
    }
    
    
}
