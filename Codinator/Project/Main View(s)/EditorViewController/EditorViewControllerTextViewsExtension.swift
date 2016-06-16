//
//  EditorViewControllerTextViewsExtension.swift
//  Codinator
//
//  Created by Vladimir Danila on 06/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation
import AudioToolbox

extension EditorViewController {
    
    func setUpTextView(_ textView: CYRTextView) {
        // Setting up TextView
        textView.frame = self.view.frame
        textView.text = text
        textView.delegate = self
        textView.tintColor = UIColor.white()
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
    
    
    
    
    func setUpHTMLTextViewKeyboard(_ textView: HTMLTextView) {
        textView.inputAssistantItem.allowsHidingShortcuts = false
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._tab))
        
        let tagOpeningSnippet = UIBarButtonItem(image: UIImage(named: "smallerThan"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._openTag))
        let tagCloseSymbolnippet = UIBarButtonItem(image: UIImage(named: "tagCloseSymbol"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._closeTagHTML))
        let tagClosingSnippet = UIBarButtonItem(image: UIImage(named: "greaterThan"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._closeTag))
        let equalSnippet = UIBarButtonItem(image: UIImage(named: "equal"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._equal))
        let stringSnippet = UIBarButtonItem(image: UIImage(named: "quoteSign"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._string))
        let percentSnippet = UIBarButtonItem(image: UIImage(named: "percent"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._percent))
        let hashSnippet = UIBarButtonItem(image: UIImage(named: "hash"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._hash))
        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, at: 0)
        
        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [tagOpeningSnippet, tagCloseSymbolnippet, tagClosingSnippet, equalSnippet, stringSnippet, percentSnippet, hashSnippet], representativeItem: nil)
        textView.inputAssistantItem.trailingBarButtonGroups = [trailingGroup]
    }
    
    func setUpJSTextViewKeyboard(_ textView: JsTextView) {
        textView.inputAssistantItem.allowsHidingShortcuts = false
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._tab))

        let stringSnippet = UIBarButtonItem(image: UIImage(named: "quoteSign")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._string))
        let dollarSnippet = UIBarButtonItem(image: UIImage(named: "dollar")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._dollar))
        let openSnippet = UIBarButtonItem(image: UIImage(named: "bracketOpenSC")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._insertOpenBracket))
        let closeSnippet = UIBarButtonItem(image: UIImage(named: "bracketCloseSC")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._insertCloseBracket))
        let commaSnippet = UIBarButtonItem(image: UIImage(named: "comma")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._comma))
        let equalSnippet = UIBarButtonItem(image: UIImage(named: "equal")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._equal))
        let apostropheSnippet = UIBarButtonItem(image: UIImage(named: "apostrophe")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._apostrophe))
        let plusSnippet = UIBarButtonItem(image: UIImage(named: "plus")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._plus))
        let clojureOpenSnippet = UIBarButtonItem(image: UIImage(named: "clojureOpen")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._clojureOpen))
        let clojureCloseSnippet = UIBarButtonItem(image: UIImage(named: "clojureClose")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._clojureClose))
        
        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, at: 0)

        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [stringSnippet, dollarSnippet, openSnippet, closeSnippet, commaSnippet, equalSnippet, apostropheSnippet, plusSnippet, clojureOpenSnippet, clojureCloseSnippet], representativeItem: nil)
        textView.inputAssistantItem.trailingBarButtonGroups = [trailingGroup]

    }
    
    func setUpCSSTextViewKeyboard(_ textView: CSSTextView) {
        textView.inputAssistantItem.allowsHidingShortcuts = false
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._tab))
        
        let commaSnippet = UIBarButtonItem(image: UIImage(named: "comma")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._comma))
        let clojureOpenSnippet = UIBarButtonItem(image: UIImage(named: "clojureOpen")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._clojureOpen))
        let clojureCloseSnippet = UIBarButtonItem(image: UIImage(named: "clojureClose")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._clojureClose))
        let minusSnippet = UIBarButtonItem(image: UIImage(named: "minus")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._minus))
        let doubleDotsSnippet = UIBarButtonItem(image: UIImage(named: "doubleDotsSC")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._doublePoint))
        let hashSnippet = UIBarButtonItem(image: UIImage(named: "hash")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditorViewController._hash))

        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, at: 0)

        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [commaSnippet ,clojureOpenSnippet, clojureCloseSnippet, minusSnippet, doubleDotsSnippet, hashSnippet], representativeItem: nil)
        textView.inputAssistantItem.trailingBarButtonGroups = [trailingGroup]

        
    }
    
    
    
    
    func setUpKeyboardForTextView(_ textView: CYRTextView) {
        // Keyboard Accessory
        
        if UIDevice.current().userInterfaceIdiom == .pad {
            return
        }
        else {
            if self.view.traitCollection.horizontalSizeClass == .compact || self.view.traitCollection.verticalSizeClass == .compact || UIDevice.current().userInterfaceIdiom == .phone {
                
                textView.inputAccessoryView = VWASAccessoryView(textView: textView)
                
            }
        }
    }
    
    
    
    
    // MARK: - Snippets
    
    @objc private func _tab() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("    ")
    }
    
    @objc private func _insertOpenBracket() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("(")
    }

    @objc private func _insertCloseBracket() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText(")")
    }
    
    @objc private func _closeTag() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText(">")
    }
    
    @objc private func _openTag() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("<")
    }
    
    @objc private func _hash() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("#")
    }
    
    @objc private func _string() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("\"\"")
        moveCursor(by: 1, diretion: .back)
    }
    
    @objc private func _equal() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("= ")
    }
    
    @objc private func _percent() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("%")
    }
    
    @objc private func _clojureOpen() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("{\n   \n} ")
    }

    @objc private func _doublePoint() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText(": ")
    }
    
    @objc private func _clojureClose() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("}")
    }

    @objc private func _plus() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("+")
    }
    
    @objc private func _minus() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("-")
    }

    @objc private func _comma() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText(";")
        indentReturn(with: self.textView.selectedRange)
    }
    @objc private func _dollar() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("$")
    }

    @objc private func _apostrophe() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("''")
    }

    @objc private func _closeTagHTML() {
        AudioServicesPlaySystemSound(1104)
        self.textView.insertText("/")
    }

    
}
