//
//  AspectRatioViewController.swift
//  VWAS-HTML
//
//  Created by Vladimir on 01/05/15.
//  Copyright (c) 2015 Vladimir Danila. All rights reserved.
//

import UIKit
import WebKit


class AspectRatioViewController: UIViewController {
    
    var webView: WKWebView!
    var previewURL: URL!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Configure WebView
        let configuration = WKWebViewConfiguration()
     
        configuration.applicationNameForUserAgent = "Codinator"
        configuration.allowsAirPlayForMediaPlayback = true
        if #available(iOS 10.0, *) { configuration.mediaTypesRequiringUserActionForPlayback = .all }
        configuration.allowsPictureInPictureMediaPlayback = true
        
        
        
        // Display up WebView
        webView = WKWebView(frame: self.view.frame, configuration:configuration)
        webView.allowsLinkPreview = true
        
        self.view.addSubview(webView)
    
        // Autoresizing for webview
        webView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleHeight, .flexibleWidth]
    
        
        webView.bindFrameToSuperviewBounds()
    
        
    
        // Load url
        webView.loadFileURL(previewURL, allowingReadAccessTo: try! previewURL.deletingLastPathComponent())
    }

    
    
    // MARK: - Shortcuts
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    override var keyCommands: [UIKeyCommand]? {
        
        return [UIKeyCommand(input: "W", modifierFlags: .command, action: #selector(AspectRatioViewController.close), discoverabilityTitle: "Close Window")]
    }

    
    
    //MARK: print
    
    @IBAction func printDidPush(_ sender: AnyObject) {
        
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "CnProj Webpage"
        printInfo.orientation = UIPrintInfoOrientation.portrait
        printInfo.duplex = UIPrintInfoDuplex.longEdge
        
        
        let printInteractionController = UIPrintInteractionController.shared()
        printInteractionController.printInfo = printInfo
        printInteractionController.printFormatter = self.webView.viewPrintFormatter()
        
        
        printInteractionController.present(animated: true, completionHandler: nil)
        
    }
    
    
    // MARK: - Relaod
    
    @IBAction func refreshDidPush() {
        webView.reload()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func close(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "resetCloseBool"), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func closeDidPush(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "resetCloseBool"), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil);
    }



}
