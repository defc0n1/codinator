//
//  EditorViewControllerAutoCompletion.swift
//  Codinator
//
//  Created by Vladimir Danila on 24/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension EditorViewController: WUTextSuggestionDisplayControllerDataSource {

    func textSuggestionDisplayController(_ textSuggestionDisplayController: WUTextSuggestionDisplayController!, suggestionDisplayItemsFor suggestionType: WUTextSuggestionType, query suggestionQuery: String!) -> [Any]! {
        if suggestionType != .none {
            var suggestionDisplayItems : [WUTextSuggestionDisplayItem] = []
            for name in self.filteredNames(query: suggestionQuery, type: suggestionType) {
                let item = WUTextSuggestionDisplayItem(title: name)
                suggestionDisplayItems.append(item!)
            }
            return suggestionDisplayItems
        }
        
        return nil;
    }
    
    func filteredNames(query : String, type: WUTextSuggestionType) -> [String] {
        let suggetionsArray = type == .tag ? htmlSuggestions : jsSuggestions
        let filteredNames = suggetionsArray.filter { $0.lowercased().hasPrefix(query.lowercased()) }
        
        
        if suggetionsArray == jsSuggestions {
            var range = self.jsTextView.selectedRange
            
            if range.location - 5 > 0 {
                range.location -= 5
            }
            
            
            // TODO: - Check if this works
            if (5 + range.location) <= jsTextView.text.characters.count {
                range.length = 5
            }
            
            
            let text = (jsTextView.text as NSString).substring(with: range)
            
            let fineFilteredNames = filteredNames.filter { text.contains($0) }
            
            // If you are currently editing the variable suggested return nothing
            if fineFilteredNames.count > 0 {
                return []
            }
            
            
            
        }
        
        
        return filteredNames
    }
    
    
    
    func cssSuggestions() -> [String] {
        return []
    }
    
    func range() {
        
        guard let rangeString = UserDefaults.standard.string(forKey: "range") else {
            return
        }
        
        print("isHTML: \(htmlSuggestions.contains(rangeString))")
        
        if htmlSuggestions.contains(rangeString) {
            htmlAutocompletion(completion: rangeString)
        }
        else if jsSuggestions.contains(rangeString) {
            jsAutocompletion(completion: rangeString)
        }
        
        
    }
    
    enum MoveCursorDirection {
        case back
        case forward
    }

    func moveCursor(by number: Int, diretion: MoveCursorDirection) {
        let range = textView.selectedRange
        
        switch diretion {
        case .back:
            textView.selectedRange = NSMakeRange(range.location - number, 0)
            
        case .forward:
            textView.selectedRange = NSMakeRange(range.location + number, 0)
        }
    }
    
    
    
    
    // Auto completion for languages
    
    func jsAutocompletion(completion: String) {
        
        // Delete everything that is already typed in
        func subString() -> String {
            
            let location = jsTextView.selectedRange.location - 1
            let maxLocation = location > 0 ? location : location + 1
            
            return (jsTextView.text as NSString).substring(with: NSMakeRange(maxLocation, 1))
        
        }
        
        while subString() != " " && subString() != "\t" && subString() != "\n" && subString() != "}" && subString() != "{" && subString() != "=" && subString() != ";" {
            print("S:" + subString() + ":")
            self.jsTextView.deleteBackward()
        }
        
        jsTextView.insertText(completion)
        
        
        if completion.contains("(") && completion.contains(")") {
            
            // '(' Position in String
            let bracketPosition = completion.characters.enumerated().filter { $0.element == Character("(") }.first!.offset
            
            // Calculate position backward
            self.moveCursor(by: completion.characters.count - bracketPosition + 1, diretion: .back)
        
        }
        else if completion.contains("{") && completion.contains("}") {
            // last '\n' Position in String
            let bracketPosition = completion.characters.enumerated().filter { $0.element == Character("\n") }.last!.offset
            
            // Calculate position backward
            self.moveCursor(by: completion.characters.count - bracketPosition, diretion: .back)
        }
        else {
            jsTextView.insertText(" ")
        }
        
    }

    func htmlAutocompletion(completion: String) {
        
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
        
        if (findTag == nil) {
            findTag = 0
        }
        
        if findCloseBracket == nil {
            findCloseBracket = 0
        }
        
        // Try to find the distance between the cursor and the beginning of the tag. Since we don't want to delete the tag we do +1
        let itemsToDeleteTillTag = stringFromRange.characters.count - findTag! - 1
        let itemsToDeleteTillCloseTag = stringFromRange.characters.count - findCloseBracket! - 1

        
        // Delete the charachters that are after the tag
        let needsOpenAndCloseTag = findTag! >= findCloseBracket!
        
        if needsOpenAndCloseTag {

            if itemsToDeleteTillTag > 0 {
                for _ in 1...itemsToDeleteTillTag {
                    htmlTextView.deleteBackward()
                }

            }

        }
        else {

            if itemsToDeleteTillTag > 0 {
                for _ in 1...itemsToDeleteTillCloseTag {
                    htmlTextView.deleteBackward()
                }
            }

        }

        
        
        
        // Complete the tag
        
        
        
        var checkString : String {
            if completion.characters.last == " " {
                return completion.substring(to: completion.characters.index(before: completion.endIndex))
            }
            else {
                return completion
            }
        }
        
        
        // Check if tag needs closing tag or not and insert the tag
        switch checkString {
        case "h1>", "h2>", "h3>",  "h4>", "h5>", "h6>", "head>", "body>", "!Documentype html>", "center>", "tr>", "title>", "li>", "section>", "header>", "footer>", "ul>", "del>", "em>", "sub>", "sup>", "small>", "strong>", "code>", "blackquote>", "p>":
            
            let br = needsOpenAndCloseTag ? "</\(checkString)" : ""
            
            htmlTextView.insertText(checkString + br)
            
            // Move cursor back +1 since count starts with 0
            self.moveCursor(by: br.characters.count, diretion: .back)
            
            
        default:
            let br = checkString
            htmlTextView.insertText(br)
            
        }

        
    }
    
}
