//
//  EditorViewControllerTextViewsExtension.swift
//  Codinator
//
//  Created by Vladimir Danila on 06/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension EditorViewController {
    
    func setUpTextView(textView: CYRTextView) {
        // Setting up TextView
        textView.frame = self.view.frame
        textView.text = text
        textView.delegate = self
        textView.tintColor = UIColor.whiteColor()
        textView.alwaysBounceVertical = true
        
        view.addSubview(textView)
        textView.bindFrameToSuperviewBounds()
        
        
        // Keyboard

        switch textView {
        case htmlTextView:
            setUpHTMLTextViewKeyboard(htmlTextView)
            
        case jsTextView:
            setUpJSTextViewKeyboard(jsTextView)
            
        case cssTextView:
            setUpCSSTextViewKeyboard(cssTextView)
            
        default:
            textView.inputAssistantItem.trailingBarButtonGroups = []
            textView.inputAssistantItem.leadingBarButtonGroups = []
        }
        
        
    }
    
    
    
    
    func setUpHTMLTextViewKeyboard(textView: HTMLTextView) {
        textView.inputAssistantItem.allowsHidingShortcuts = false
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._tab))
        
        let tagOpeningSnippet = UIBarButtonItem(image: UIImage(named: "smallerThan"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._openTag))
        let tagClosingSnippet = UIBarButtonItem(image: UIImage(named: "greaterThan"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._closeTag))
        let equalSnippet = UIBarButtonItem(image: UIImage(named: "equal"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._equal))
        let stringSnippet = UIBarButtonItem(image: UIImage(named: "quoteSign"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._string))
        let percentSnippet = UIBarButtonItem(image: UIImage(named: "percent"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._percent))
        let hashSnippet = UIBarButtonItem(image: UIImage(named: "hash"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._hash))
        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, atIndex: 0)
        
        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [tagOpeningSnippet, tagClosingSnippet, equalSnippet, stringSnippet, percentSnippet, hashSnippet], representativeItem: nil)
        textView.inputAssistantItem.trailingBarButtonGroups = [trailingGroup]

    }
    
    func setUpJSTextViewKeyboard(textView: JsTextView) {
        textView.inputAssistantItem.allowsHidingShortcuts = false
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._tab))

        let stringSnippet = UIBarButtonItem(image: UIImage(named: "quoteSign")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._string))
        let dollarSnippet = UIBarButtonItem(image: UIImage(named: "dollar")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._dollar))
        let openSnippet = UIBarButtonItem(image: UIImage(named: "bracketOpenSC")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._insertOpenBracket))
        let closeSnippet = UIBarButtonItem(image: UIImage(named: "bracketCloseSC")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._insertCloseBracket))
        let commaSnippet = UIBarButtonItem(image: UIImage(named: "comma")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._comma))
        let equalSnippet = UIBarButtonItem(image: UIImage(named: "equal")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._equal))
        let apostropheSnippet = UIBarButtonItem(image: UIImage(named: "apostrophe")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._apostrophe))
        let plusSnippet = UIBarButtonItem(image: UIImage(named: "plus")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._plus))
        let clojureOpenSnippet = UIBarButtonItem(image: UIImage(named: "clojureOpen")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._clojureOpen))
        let clojureCloseSnippet = UIBarButtonItem(image: UIImage(named: "clojureClose")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._clojureClose))
        
        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, atIndex: 0)

        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [stringSnippet, dollarSnippet, openSnippet, closeSnippet, commaSnippet, equalSnippet, apostropheSnippet, plusSnippet, clojureOpenSnippet, clojureCloseSnippet], representativeItem: nil)
        textView.inputAssistantItem.trailingBarButtonGroups = [trailingGroup]

    }
    
    func setUpCSSTextViewKeyboard(textView: CSSTextView) {
        textView.inputAssistantItem.allowsHidingShortcuts = false
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._tab))
        
        let commaSnippet = UIBarButtonItem(image: UIImage(named: "comma")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._comma))
        let clojureOpenSnippet = UIBarButtonItem(image: UIImage(named: "clojureOpen")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._clojureOpen))
        let clojureCloseSnippet = UIBarButtonItem(image: UIImage(named: "clojureClose")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._clojureClose))
        let minusSnippet = UIBarButtonItem(image: UIImage(named: "minus")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._minus))
        let doubleDotsSnippet = UIBarButtonItem(image: UIImage(named: "doubleDotsSC")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._doublePoint))
        let hashSnippet = UIBarButtonItem(image: UIImage(named: "hash")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._hash))

        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, atIndex: 0)

        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [commaSnippet ,clojureOpenSnippet, clojureCloseSnippet, minusSnippet, doubleDotsSnippet, hashSnippet], representativeItem: nil)
        textView.inputAssistantItem.trailingBarButtonGroups = [trailingGroup]

        
    }
    
    
    
    
    func setUpKeyboardForTextView(textView: CYRTextView) {
        // Keyboard Accessory
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return
        }
        else {
            if self.view.traitCollection.horizontalSizeClass == .Compact || self.view.traitCollection.verticalSizeClass == .Compact || UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                
                textView.inputAccessoryView = VWASAccessoryView(textView: textView)
                
            }
        }
    }
    
    
    
    
    // MARK: - Snippets
    
    @objc private func _tab() {
        self.textView.insertText("    ")
    }
    
    @objc private func _insertOpenBracket() {
        self.textView.insertText("(")
    }

    @objc private func _insertCloseBracket() {
        self.textView.insertText(")")
    }
    
    @objc private func _closeTag() {
        self.textView.insertText(">")
    }
    
    @objc private func _openTag() {
        self.textView.insertText("<")
    }
    
    @objc private func _hash() {
        self.textView.insertText("#")
    }
    
    @objc private func _string() {
        self.textView.insertText("\"")
    }
    
    @objc private func _equal() {
        self.textView.insertText("=")
    }
    
    @objc private func _percent() {
        self.textView.insertText("%")
    }
    
    @objc private func _clojureOpen() {
        self.textView.insertText("{")
    }

    @objc private func _doublePoint() {
        self.textView.insertText(":")
    }
    
    @objc private func _clojureClose() {
        self.textView.insertText("}")
    }

    @objc private func _plus() {
        self.textView.insertText("+")
    }
    
    @objc private func _minus() {
        self.textView.insertText("-")
    }

    @objc private func _comma() {
        self.textView.insertText(";")
    }
    @objc private func _dollar() {
        self.textView.insertText("$")
    }

    @objc private func _apostrophe() {
        self.textView.insertText("'")
    }

    
}