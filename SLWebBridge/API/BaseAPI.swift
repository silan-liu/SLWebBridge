//
//  BaseAPI.swift
//  SLWebBridge
//
//  Created by silan on 16/10/11.
//  Copyright © 2016年 summer. All rights reserved.
//

import UIKit

class BaseAPI: NSObject, APIProtocol {
    
    func module() -> String {
        return ""
    }
    
    func callNativeMethod(name: String, parameter: [String: AnyObject], callback: SLCallback) {
        let seletor = NSSelectorFromString("hah")
        let imp = self.method(for: seletor)
        
        if let imp = imp {
            typealias function = @convention(c) (AnyObject, Selector, AnyObject) -> Void
            
            let callback = unsafeBitCast(imp, to: function.self)
            
            callback("a" as AnyObject, seletor, "stuff" as AnyObject)
        }
    }
}
