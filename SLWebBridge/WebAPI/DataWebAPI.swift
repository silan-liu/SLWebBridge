//
//  DataWebAPI.swift
//  SLWebBridge
//
//  Created by liusilan on 17/3/10.
//  Copyright © 2017年 summer. All rights reserved.
//

import Foundation

class DataWebAPI: BaseWebAPI {
    func test(_ params:[String: AnyObject]?, callback: SLCallback?) {
        print("test DataWebAPI");
        if let params = params {
            print("params:\(params)")
        }
        
        callback?(["a":22])
    }
}
