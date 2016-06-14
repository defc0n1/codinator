//
//  extension.swift
//  VWAS-HTML
//
//  Created by Vladimir on 05/05/15.
//  Copyright (c) 2015 Vladimir Danila. All rights reserved.
//

import Foundation



extension NSObject {
    
    func callSelectorAsync(_ selector: Selector, object: AnyObject?, delay: TimeInterval) -> Timer {
        
        let timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: selector, userInfo: object, repeats: false)
        return timer
    }
    
    func callSelector(_ selector: Selector, object: AnyObject?, delay: TimeInterval) {
        
        let delay = delay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.after(when: time) { 
            Thread.detachNewThreadSelector(selector, toTarget: self, with: object)
        }
    }
}


