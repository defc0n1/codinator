//
//  PlaygroundViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 29/06/15.
//  Copyright © 2015 Vladimir Danila. All rights reserved.
//

import UIKit
import SafariServices

final class PlaygroundViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var changeFileSegment: UISegmentedControl!
    
    var rootHTML: CGRect = CGRect()
    var rootCSS: CGRect = CGRect()
    var rootJS: CGRect = CGRect()
    
    var document: PlaygroundDocument!
    var filePath: String!

    
    var neuronTextView: NeuronTextView = NeuronTextView()
    var cssTextView: CSSTextView = CSSTextView()
    var jsTextView: JsTextView = JsTextView()
   
    
    var neuronText: String = ""
    var cssText: String = ""
    var jsText: String = ""
    
    
    
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var textViewSpace: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        document = PlaygroundDocument(fileURL: URL(fileURLWithPath: filePath, isDirectory: false))
        document.open { (success) -> Void in
            
            if (success){
                if (self.document.contents.count == 3){
                    self.neuronText = self.document.contents[0] as! String
                    self.cssText = self.document.contents[1] as! String
                    self.jsText = self.document.contents[2] as! String
                }
                self.navigationItem.title = (self.document.fileURL.lastPathComponent as NSString).deletingPathExtension + " Playground"
                
            }
            else{
                //Error
                print("Error opening file")
            }
            
        }
        
        
        // Set up frames
        
        self.applyFramesForViewSize(self.textViewSpace.frame.size)
        
        self.neuronTextView.backgroundColor = UIColor.black
        self.cssTextView.backgroundColor = UIColor.black
        self.jsTextView.backgroundColor = UIColor.black
        
        
        // Add to subView
        self.textViewSpace.addSubview(self.cssTextView)
        self.textViewSpace.addSubview(self.jsTextView)
        self.textViewSpace.addSubview(self.neuronTextView)
        
        
        
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        applyFramesForViewSize(textViewSpace.frame.size)
        let appearance = UIKeyboardAppearance.dark
        
        self.neuronTextView.alwaysBounceVertical = true
        self.cssTextView.alwaysBounceVertical = true
        self.jsTextView.alwaysBounceVertical = true
        
        self.neuronTextView.keyboardAppearance = appearance
        self.cssTextView.keyboardAppearance = appearance
        self.jsTextView.keyboardAppearance = appearance
        
        self.neuronTextView.keyboardDismissMode = .interactive
        self.cssTextView.keyboardDismissMode = .interactive
        self.jsTextView.keyboardDismissMode = .interactive
        
        let textViewTintColor = UIColor.white
        self.neuronTextView.tintColor = textViewTintColor
        self.cssTextView.tintColor = textViewTintColor
        self.jsTextView.tintColor = textViewTintColor
        
        
        // Create keyboard
        
        let snippet = UIBarButtonItem(image: UIImage(named: "tab"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlaygroundViewController.insertTab))
        let snippetOne = UIBarButtonItem(image: UIImage(named: "quoteSign"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlaygroundViewController.insertStringSnippet))
        let snippetTwo = UIBarButtonItem(image: UIImage(named: "bracketOpenSC"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlaygroundViewController.insertOpenBracket))
        let snippetThree = UIBarButtonItem(image: UIImage(named: "bracketCloseSC"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlaygroundViewController.insertCloseBracket))
        let snippetFour = UIBarButtonItem(image: UIImage(named: "doubleDotsSC"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlaygroundViewController.insertDoublePoint))
        
        let barButtonItems = [snippet,snippetOne, snippetTwo, snippetThree, snippetFour];
        
        let group = UIBarButtonItemGroup(barButtonItems: barButtonItems, representativeItem: nil)
        neuronTextView.inputAssistantItem.trailingBarButtonGroups = [group]
        
        
        
        
        self.neuronTextView.tag = 1
        self.cssTextView.tag = 2
        self.jsTextView.tag = 3
    
        
        
        self.neuronTextView.text = neuronText
        self.cssTextView.text = cssText
        self.jsTextView.text = jsText
        self.setUpPlayground()
        
        
        
        
        self.neuronTextView.delegate = self
        self.cssTextView.delegate = self
        self.jsTextView.delegate = self
        
        if (self.view.bounds.size.width <= 1000){
            self.cssTextView.isHidden = true
            self.jsTextView.isHidden = true
        }
        
        
        let resizingMask: UIViewAutoresizing = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        
        self.neuronTextView.autoresizingMask = resizingMask
        self.cssTextView.autoresizingMask = resizingMask
        self.jsTextView.autoresizingMask = resizingMask
        
        
        let key = "PlaygroundQSGWasDisplayedOnce"
        let display = UserDefaults.standard.bool(forKey: key)
        
        if display == false {
            self.performSegue(withIdentifier: "QSG", sender: self)
            UserDefaults.standard.set(true, forKey: key)
        }
     
    }
    
    
    
    //MARK: Delegates
    
    func textViewDidChange(_ textView: UITextView) {
        
        let tmpPath = NSTemporaryDirectory()
        
        // Save the recent change
        switch (textView.tag) {
        
        case 1:
            
            do{
               self.document.contents[0] = self.neuronTextView.text
                
                let cssString = self.document.contents[1] as! String
                let jsString = self.document.contents[2] as! String
                
                try Neuron.neuronCode(self.neuronTextView.text, cssString: cssString, jsString: jsString).write (toFile: tmpPath + "/index.html", atomically: true, encoding: String.Encoding.utf8)
                
            }
            catch{
                //ERROR
                
                
                print("Error copying file to tmp path")
                
            }
            
            
            
            
            break
        case 2:
            
            do{
                document.contents[1] = self.cssTextView.text
                
                let startingHTMLString = self.document.contents[0] as! String
                let jsString = self.document.contents[2] as! String
                
                try Neuron.neuronCode(startingHTMLString, cssString: cssTextView.text, jsString: jsString).write(toFile: tmpPath + "/index.html", atomically: true, encoding: String.Encoding.utf8)
                
            }
            catch{
                //ERROR
            }
            
            
            break
        case 3:
            
            do{
                document.contents[2] = self.jsTextView.text
                
                let startingHTMLString = self.document.contents[0] as! String
                let cssString = self.document.contents[1] as! String
                
                try Neuron.neuronCode(startingHTMLString, cssString: cssString, jsString: self.jsTextView.text).write(toFile: tmpPath + "/index.html", atomically: true, encoding: String.Encoding.utf8)
                
            }
            catch{
                //ERROR
            }
            
            break
            
        default:
            break
        }
        
        
        let url = URL(fileURLWithPath: tmpPath + "/index.html", isDirectory: false)
        let request = URLRequest(url: url)
        
        self.webView.loadRequest(request)
        
    }
    
    var length = 0
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if length >= 8 || text.characters.count > 8 {
            length = 0
            print("File will save..")
            document.save(to: URL(fileURLWithPath: filePath), for: UIDocumentSaveOperation.forOverwriting) { (success) -> Void in
                if success {
                    print("Playground file was saved")
                }
                else {
                    print("Failed Saving playground file")
                }
            }
        }
        else {
            
            if text != " " {
                length += text.characters.count
            }
        }

        
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {


        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            let noInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            textView.contentInset = noInsets
            textView.scrollIndicatorInsets = noInsets
            
            self.applyFramesForViewSize(self.textViewSpace.frame.size)
            
            }, completion: nil)
        
    }
    
    
    
    //MARK: Set UP II
    
    func setUpPlayground() {
        
        let tmpPath = NSTemporaryDirectory()
        
        let startingHTMLString = self.document.contents[0] as! String
        let cssString = self.document.contents[1] as! String
        let jsString = self.document.contents[2] as! String
        
        try! Neuron.neuronCode(startingHTMLString, cssString: cssString, jsString: jsString).write(toFile: tmpPath + "/index.html", atomically: true, encoding: String.Encoding.utf8)
        
        
        let url = URL(fileURLWithPath: tmpPath + "/index.html", isDirectory: false)
        let request = URLRequest(url: url)
        
        self.webView.loadRequest(request)
        
    }
    
    
    
    //MARK: Small screen devices only
    
    
    
    @IBAction func segmentDidChanged(_ sender: UISegmentedControl) {
        neuronTextView.resignFirstResponder()
        cssTextView.resignFirstResponder()
        jsTextView.resignFirstResponder()
        
        switch (sender.selectedSegmentIndex){
            
        case 0:
            self.neuronTextView.isHidden = false
            self.cssTextView.isHidden = true
            self.jsTextView.isHidden = true
            break
        case 1:
            self.neuronTextView.isHidden = true
            self.cssTextView.isHidden = false
            self.jsTextView.isHidden = true
            break
        case 2:
            self.neuronTextView.isHidden = true
            self.cssTextView.isHidden = true
            self.jsTextView.isHidden = false
            break
        default:
            break
        }
        
        
        
    }
    

    
    //MARK: Snippets

    func insertTab(){
        self.neuronTextView.insertText("    ");
    }
    
    func insertStringSnippet(){
        self.neuronTextView.insertText("\"");
    }

    func insertOpenBracket(){
        self.neuronTextView.insertText("(");
    }
    
    func insertCloseBracket(){
        self.neuronTextView.insertText(")");
    }
    
    func insertDoublePoint(){
        self.neuronTextView.insertText(":");
    }
    
    
    //MARK: Extra
    
    @IBAction func closeDidPush(_ sender: AnyObject) {
        
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
        
        self.document.close { saved in
            
            if saved {
                
                _ = self.navigationController?.popToRootViewController(animated: true)
                
            }
            
            
            
        }
            
//            self.document.saveToURL(NSURL(fileURLWithPath: self.filePath), forSaveOperation: UIDocumentSaveOperation.ForOverwriting) { (success) -> Void in
//                
//                if (success){
//                    
//                    self.document.closeWithCompletionHandler({ (success) -> Void in
//                        if (success){
//                            self.navigationController?.popToRootViewControllerAnimated(true)
//                        }
//                    })
//                }
//                else {
//                    Notifications.sharedInstance.alertWithMessage("Failed saving playground", title: nil, viewController: self)
//                }
//                
//            }
//
        
//        }
        
    }
    
    
    @IBAction func actionsDidPush(_ sender: UIBarButtonItem) {
        
        let popup = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        popup.view.tintColor = UIColor.orange
        
        popup.popoverPresentationController?.barButtonItem = sender
        
        
        let printAction = UIAlertAction(title: "Print 📠", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
            
            let pi = UIPrintInfo.printInfo()
            pi.outputType = UIPrintInfoOutputType.general
            pi.jobName = "Print Playground"
            pi.orientation = UIPrintInfoOrientation.portrait
            pi.duplex = UIPrintInfoDuplex.longEdge
            
            
            let pic = UIPrintInteractionController.shared
            pic.printInfo = pi
            pic.printFormatter = self.webView.viewPrintFormatter()
            
            pic.present(animated: true, completionHandler: nil)
            
        }
        
        let convertAction = UIAlertAction(title: "Copy Converted to Clipboard 📎", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
            
            
            let startingHTMLString = self.document.contents[0] as! String
            let cssString = self.document.contents[1] as! String
            let jsString = self.document.contents[2] as! String
            
            let pasteboard = UIPasteboard.general
            pasteboard.string = Neuron.neuronCode(startingHTMLString, cssString: cssString, jsString: jsString)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        popup.addAction(printAction)
        popup.addAction(convertAction)
        popup.addAction(cancel)
        
        self.present(popup, animated: true, completion: nil)
        
        
        
    }
    
    
    @IBAction func documentationDidPush(_ sender: UIBarButtonItem) {
        
        let popup = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        popup.view.tintColor = UIColor.orange
        
        popup.popoverPresentationController?.barButtonItem = sender
        
        let documetationAction = UIAlertAction(title: "Neuron Documentation 📚", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
            
            let url: URL = URL(string: "http://vwas.cf/neuron/docs")!
            
            let safariVC: SFSafariViewController = SFSafariViewController(url: url)
            safariVC.view.tintColor = self.view.tintColor
            
            safariVC.modalPresentationStyle = .formSheet
            
            self.present(safariVC, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        popup.addAction(documetationAction)
        popup.addAction(cancelAction)
        
        self.present(popup, animated: true, completion: nil)
        
        self.neuronTextView.frame = rootHTML
        self.cssTextView.frame = rootCSS
        self.jsTextView.frame = rootJS
        
    }
    
    // MARK: - Frames
    
    func applyFramesForViewSize(_ size: CGSize) {
        
        // Set up frames
        
        
        self.rootHTML = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.rootCSS = rootHTML
        self.rootJS = rootHTML
        
        
        self.neuronTextView.frame = rootHTML
        self.cssTextView.frame = rootCSS
                self.jsTextView.frame = rootJS

        
        
    }
    
    //MARK: Layout Managing

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        applyFramesForViewSize(textViewSpace.frame.size)
        
    }
    
}
