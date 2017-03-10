//
//  BaseWebAPI.swift
//  SLWebBridge
//
//  Created by liusilan on 17/3/10.
//  Copyright © 2017年 summer. All rights reserved.
//

import Foundation

class BaseWebAPI: NSObject, WebAPIProtocol {
    
    func module() -> String {
        return ""
    }
    
    func callNativeMethod(name: String, parameter: [String: AnyObject]?, callback: SLCallback?) {
        let sel = name + ":callback:"
        let seletor = NSSelectorFromString(sel)
        
        guard self.responds(to: seletor) else {
            print("\(self) not responds \(sel)")
            return
        }
        
        let imp = self.method(for: seletor)
        
        if let imp = imp {
            typealias function = @convention(c) (AnyObject, Selector, [String: AnyObject]?, SLCallback?) -> Void
            
            let call = unsafeBitCast(imp, to: function.self)
            
            call(self, seletor, parameter, callback)
        }
        
        if let callback = callback {
            callback(nil)
        }
    }
}
