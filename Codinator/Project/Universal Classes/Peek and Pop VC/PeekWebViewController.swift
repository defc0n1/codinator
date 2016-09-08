//
//  PeekWebViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 25/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class PeekWebViewController: AspectRatioViewController {

    weak var delegate: PeekProtocol?
    
    var projectsDelegate: PeekShortProtocol?
    var isProjects = false


    override var previewActionItems: [UIPreviewActionItem] {
        
        if isProjects {
            
            let renameAction = UIPreviewAction(title: "Rename", style: .default, handler: { _ in
                self.delegate?.rename()
                self.projectsDelegate?.rename()
            })
            
            let deleteAction = UIPreviewAction(title: "Delete", style: .destructive, handler: { _ in
                self.delegate?.delete()
                self.projectsDelegate?.delete()
            })
            
            
            return [renameAction, deleteAction]
        }
        else {
            let printAction = UIPreviewAction(title: "Print", style: .default, handler: { _ in
                self.delegate?.peekPrint()
            })
            
            
            let moveAction = UIPreviewAction(title: "Move file", style: .default, handler: { _ in
                self.delegate?.move()
            })
            
            
            let renameAction = UIPreviewAction(title: "Rename", style: .default, handler: { _ in
                self.delegate?.rename()
            })
            
            let shareAction = UIPreviewAction(title: "Share", style: .default, handler: { _ in
                self.delegate?.share()
            })
            
            let deleteAction = UIPreviewAction(title: "Delete", style: .destructive, handler: { _ in
                self.delegate?.delete()
            })
            
            
            return [printAction, moveAction, renameAction, shareAction, deleteAction]
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        webView.scalesPageToFit = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension WKWebView {
    private struct key {
        static let scale = unsafeBitCast(#selector(getter: UIWebView.scalesPageToFit), to: UnsafeRawPointer.self)
    }
    private var sourceOfUserScript: String {
        return "(function(){\n" +
            "    var head = document.getElementsByTagName('head')[0];\n" +
            "    var nodes = head.getElementsByTagName('meta');\n" +
            "    var i, meta;\n" +
            "    for (i = 0; i < nodes.length; ++i) {\n" +
            "        meta = nodes.item(i);\n" +
            "        if (meta.getAttribute('name') == 'viewport')  break;\n" +
            "    }\n" +
            "    if (i == nodes.length) {\n" +
            "        meta = document.createElement('meta');\n" +
            "        meta.setAttribute('name', 'viewport');\n" +
            "        head.appendChild(meta);\n" +
            "    } else {\n" +
            "        meta.setAttribute('backup', meta.getAttribute('content'));\n" +
            "    }\n" +
            "    meta.setAttribute('content', 'width=device-width, user-scalable=no');\n" +
        "})();\n"
    }
    var scalesPageToFit: Bool {
        get {
            return objc_getAssociatedObject(self, key.scale) != nil
        }
        set {
            if newValue {
                if objc_getAssociatedObject(self, key.scale) != nil {
                    return
                }
                let time = WKUserScriptInjectionTime.atDocumentEnd
                let script = WKUserScript(source: sourceOfUserScript, injectionTime: time, forMainFrameOnly: true)
                configuration.userContentController.addUserScript(script)
                objc_setAssociatedObject(self, key.scale, script, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                if url != nil {
                    evaluateJavaScript(sourceOfUserScript, completionHandler: nil)
                }
            } else if let script = objc_getAssociatedObject(self, key.scale) as? WKUserScript {
                objc_setAssociatedObject(self, key.scale, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                configuration.userContentController.removeUserScript(script)
                if url != nil {
                    let source = "(function(){\n" +
                        "    var head = document.getElementsByTagName('head')[0];\n" +
                        "    var nodes = head.getElementsByTagName('meta');\n" +
                        "    for (var i = 0; i < nodes.length; ++i) {\n" +
                        "        var meta = nodes.item(i);\n" +
                        "        if (meta.getAttribute('name') == 'viewport' && meta.hasAttribute('backup')) {\n" +
                        "            meta.setAttribute('content', meta.getAttribute('backup'));\n" +
                        "            meta.removeAttribute('backup');\n" +
                        "        }\n" +
                        "    }\n" +
                    "})();"
                    evaluateJavaScript(source, completionHandler: nil)
                }
            }
        }
    }
}
extension WKUserContentController {
    public func removeUserScript(_ script: WKUserScript) {
        let scripts = userScripts
        removeAllUserScripts()
        scripts.forEach {
            if $0 != script { self.addUserScript($0) }
        }
    }
}
