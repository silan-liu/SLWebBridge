//
//  WebAPIProtocol.swift
//  SLWebBridge
//
//  Created by liusilan on 17/3/10.
//  Copyright © 2017年 summer. All rights reserved.
//

import Foundation

typealias SLCallback = (_ parameter: [String: Any]?) -> Void

protocol WebAPIProtocol {
    func module() -> String
    func callNativeMethod(name: String, parameter: [String: AnyObject]?, callback: SLCallback?)
}
