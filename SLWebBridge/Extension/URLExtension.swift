//
//  URLExtension.swift
//  SLWebBridge
//
//  Created by liusilan on 17/3/10.
//  Copyright © 2017年 summer. All rights reserved.
//

import Foundation

extension URL {
    private struct AssociatedKeys {
        static var ParametersKey = "ParametersKey"
    }
    
    func scanParameters() -> [String: String]? {
        guard !self.isFileURL else {
            return nil
        }

        let scanner = Scanner(string: self.absoluteString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn:"&?")
        scanner.scanUpTo("?", into: nil)
        
        var dict = [String: String]()
        
        var temp: NSString?

        while scanner.scanUpTo("&", into: &temp) {
            let array = temp?.components(separatedBy: "=")
            if let array = array, array.count >= 2 {
                let key = array[0].removingPercentEncoding
                let value = array[1].removingPercentEncoding
                
                dict[key!] = value
            }
        }
        
        return dict
    }
    
    var parameters: [String: String]? {
        mutating get {
            var value = objc_getAssociatedObject(self, &AssociatedKeys.ParametersKey) as? [String: String]
            if value == nil {
                value = scanParameters()
                self.parameters = value
            }
            
            return value
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.ParametersKey,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    mutating func objectForKey(_ key: String) -> String? {
        if let parameters = parameters {
            return parameters[key];
        }
        
        return nil
    }
}
