//
//  APIProtocol.swift
//  SLWebBridge
//
//  Created by silan on 16/10/11.
//  Copyright © 2016年 summer. All rights reserved.
//

import Foundation

typealias SLCallback = (_ parameter: AnyObject) -> Void;

protocol APIProtocol {
    func module() -> String
    func callNativeMethod(name: String, parameter: [String: AnyObject], callback: SLCallback)
}
