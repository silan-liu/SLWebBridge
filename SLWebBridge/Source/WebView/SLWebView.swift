//
//  SLWebView.swift
//  SLWebBridge
//
//  Created by silan on 16/10/11.
//  Copyright © 2016年 summer. All rights reserved.
//

import UIKit

class SLWebView: UIWebView {
    var webBridge: WebBridge?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    deinit {
        webBridge = nil
        self.delegate = nil
    }
    
    private func commonInit() {
        webBridge = WebBridge(webView: self, webViewDelegate: nil)
    }
    
    //MARK: Register API
    func registerWebAPI(_ module: String, _ api: WebAPIProtocol) {
        webBridge?.registerWebAPI(module, api)
    }
    
    func unregisterWebAPI(_ module: String) {
        webBridge?.unregisterWebAPI(module)
    }
}
