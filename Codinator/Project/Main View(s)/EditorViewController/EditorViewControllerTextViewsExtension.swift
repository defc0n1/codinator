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
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._tab))

        let stringSnippet = UIBarButtonItem(image: UIImage(named: "quoteSign"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._string))
        //WARNING: - $
        let openSnippet = UIBarButtonItem(image: UIImage(named: "bracketOpenSC"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PlaygroundViewController.insertOpenBracket))
        let closeSnippet = UIBarButtonItem(image: UIImage(named: "bracketCloseSC"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PlaygroundViewController.insertCloseBracket))
        // WARNING: ;
        let equalSnippet = UIBarButtonItem(image: UIImage(named: "equal"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._equal))
        // WARNING: '
        // WARNING +
        // WARNING  {
        // WARNING }
        
        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, atIndex: 0)

        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [stringSnippet, openSnippet, closeSnippet, equalSnippet], representativeItem: nil)
        textView.inputAssistantItem.trailingBarButtonGroups = [trailingGroup]

    }
    
    func setUpCSSTextViewKeyboard(textView: CSSTextView) {
        textView.inputAssistantItem.allowsHidingShortcuts = false
        let tabSnippet = UIBarButtonItem(image: UIImage(named: "tab"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._tab))
        
        // WARNING: ;
        // WARNING  {
        // WARNING }
        // WARNING -
        let doubleDotsSnippet = UIBarButtonItem(image: UIImage(named: "doubleDotsSC"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PlaygroundViewController.insertDoublePoint))
        let hashSnippet = UIBarButtonItem(image: UIImage(named: "hash"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditorViewController._hash))

        
        let leadingGroup = UIBarButtonItemGroup(barButtonItems: [tabSnippet], representativeItem: nil)
        textView.inputAssistantItem.leadingBarButtonGroups.insert(leadingGroup, atIndex: 0)

        let trailingGroup = UIBarButtonItemGroup(barButtonItems: [doubleDotsSnippet, hashSnippet], representativeItem: nil)
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
    
    
    
}