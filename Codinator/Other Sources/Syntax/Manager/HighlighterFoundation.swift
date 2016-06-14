//
//  HighlighterFoundation.swift
//  Codinator
//
//  Created by Vladimir Danila on 3/30/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

enum HighlightingDictionaryKey: String {
    case Tag = "Macro:3 Attribute"
    case SquareBrackets = "Macro:4 Attribute"
    case ReservedWords = "Macro:5 Attribute"
    case String = "Macro:6 Attribute"
}

enum HighlightingMacroKey: String {
    case Tag = "Macro:3"
    case SquareBrackets = "Macro:4"
    case ReservedWords = "Macro:5"
    case String = "Macro:6"
}

class HighlighterFoundation: UITextView {
    
    var tokens: [CYRToken]? {
        get {
            
            guard let textStorage: CYRTextStorage = self.textStorage as? CYRTextStorage else {
                return []
            }
            
            guard let tokens = textStorage.tokens as? [CYRToken] else {
                return []
            }
            
            return tokens
        }
        
        set {
            if let storage = self.syntaxTextStorage {
                storage.tokens = newValue
            }
        }
        
    }
    
    var singleFingerPanRecognizer: UIPanGestureRecognizer?
    var doubleFingerPanRecognizer: UIPanGestureRecognizer?
    
    let cursorVelocity: CGFloat = 1/8
    
    let lineColor: UIColor = UIColor.black()
    let bgColor: UIColor = UIColor(white: 0, alpha: 1)
    
    var lineCursorEnabled = true
    
    var startRange: NSRange?
    
    var displayLineNumber = UserDefaults.standard().bool(forKey: "CnLineNumber")
    var lineNumberLayoutManager: CYRLayoutManager?
    
    
    // WARNING: - This is incomplete
    var syntaxLayoutManager: CYRLayoutManager?
    var syntaxTextStorage: CYRTextStorage?
    

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }

     convenience init(frame: CGRect) {
        let textStorage = CYRTextStorage()
        let layoutManager = CYRLayoutManager()
        
        
        let textContainer = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        
        //  Wrap text to the text view's frame
        textContainer.widthTracksTextView = true
        
        layoutManager.addTextContainer(textContainer)
        textStorage.removeLayoutManager(textStorage.layoutManagers.first!)
        textStorage.addLayoutManager(layoutManager)
        
        self.init(frame: frame, textContainer: textContainer)

        
        self.syntaxTextStorage = textStorage
        lineNumberLayoutManager = layoutManager

        
        self.contentMode = .redraw
        self.setUp()
        
    }
    

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        isScrollEnabled = false
        isEditable = false
    }
    
    
    
    
    func setUp() {
        
        //WARNING: - Observers arre missing 
        
        // Setup defaults 
        self.font = UIFont.systemFont(ofSize: 16.0)
        self.textColor = UIColor.white()
        
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.lineCursorEnabled = true
        
        if displayLineNumber {
            self.textContainerInset = UIEdgeInsetsMake(8, self.lineNumberLayoutManager!.gutterWidth, 8, 0)
        }
        else {
            self.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0)
        }
        
        
        // Gesture recognizer
        singleFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(singleFingerPanHappened))
        singleFingerPanRecognizer?.maximumNumberOfTouches = 1
        self.addGestureRecognizer(singleFingerPanRecognizer!)
        
        
        doubleFingerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(doubleFingerPanHappened))
        doubleFingerPanRecognizer?.maximumNumberOfTouches = 2
        self.addGestureRecognizer(doubleFingerPanRecognizer!)
        
        
    }

    
    // MARK: - Notifications

    

    
    // MARK: - Line drawing

    override func draw(_ rect: CGRect) {

        if self.displayLineNumber {
            
            //  Drag the line number gutter background.  The line numbers them selves are drawn by LineNumberLayoutManager.
            let context = UIGraphicsGetCurrentContext()
            
            let bounds = self.bounds
            let height = max(bounds.height, self.contentSize.height) + 200
            
            // Set the regular fill
            context?.setFillColor(bgColor.cgColor)
            context?.fill(CGRect(x: bounds.origin.x, y: bounds.origin.y, width: self.lineNumberLayoutManager!.gutterWidth, height: height))
            
            // Draw line
            context?.setFillColor(self.lineColor.cgColor)
            context?.fill(CGRect(x: self.lineNumberLayoutManager!.gutterWidth, y: bounds.origin.y, width: 0.5, height: height))
            
            if lineCursorEnabled {
                self.lineNumberLayoutManager!.selectedRange = self.selectedRange
                
                let string: NSString = (self.lineNumberLayoutManager?.textStorage?.string)!
                let tmpGlyphRange = string.paragraphRange(for: self.selectedRange)
                
                let glyphRange = self.lineNumberLayoutManager?.glyphRange(forCharacterRange: tmpGlyphRange, actualCharacterRange: nil)
                
                self.lineNumberLayoutManager?.selectedRange = glyphRange!
                self.lineNumberLayoutManager?.invalidateDisplay(forGlyphRange: glyphRange!)
                
            }
            
            
        }
    
        super.draw(rect)
    }
    
    
    
    
    // MARK: - Gestures
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
     
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer  {
            
            // Only accept horizontal pans for the code navigation to preserve correct scrolling behaviour.
            if panGestureRecognizer == singleFingerPanRecognizer || panGestureRecognizer == doubleFingerPanRecognizer {
                let translation = panGestureRecognizer.translation(in: self)
                return fabs(translation.x) > fabs(translation.y)
            }
            
        }
        
        return true
    }
    
    
    func singleFingerPanHappened(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began  {
            startRange = self.selectedRange
        }
        
        let cursorLocation = max(CGFloat(startRange!.location) + sender.translation(in: self).x * cursorVelocity, 0)
        
        self.selectedRange = NSMakeRange(Int(cursorLocation), 0)
    }
    
    func doubleFingerPanHappened(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began  {
            startRange = self.selectedRange
        }
        
        let cursorLocation = Int(max(CGFloat(startRange!.location) + sender.translation(in: self).x * cursorVelocity, 0))
        
        
        if cursorLocation > startRange?.location {
            self.selectedRange = NSMakeRange(startRange!.location, Int(fabs(Double(startRange!.location - cursorLocation))))
        }
        else {
            self.selectedRange = NSMakeRange(cursorLocation, Int(fabs(Double(startRange!.location - cursorLocation))))
        }
        
    }
        
    
    

}
