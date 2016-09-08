//
//  PeekImageViewController.swift
//  Codinator
//
//  Created by Vladimir Danila on 25/04/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit


class PeekImageViewController: UIViewController {

    
    weak var delegate: PeekProtocol?
    
    var isDir = false
    
    
    override var previewActionItems: [UIPreviewActionItem] {
        
        var items = [UIPreviewActionItem]()
        
        if isDir == false {
            let printAction = UIPreviewAction(title: "Print", style: .default, handler: { _ in
                self.delegate?.peekPrint()
            })
            
            items.append(printAction)
        }
        
        
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
        
        [moveAction, renameAction, shareAction, deleteAction].forEach { items.append($0) }
        
        return items
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
