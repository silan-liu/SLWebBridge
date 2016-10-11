//
//  WebBridge.swift
//  SLWebBridge
//
//  Created by silan on 16/10/11.
//  Copyright © 2016年 summer. All rights reserved.
//

import UIKit

class WebBridge: NSObject, UIWebViewDelegate {
    weak var webViewDelegate: UIWebViewDelegate?
    private weak var webView: UIWebView?
    
    init(webView: UIWebView) {
        super.init()
        
        self.webView = webView
        webView.delegate = self
        
        injectBridgeScript()
    }
    
    init(webView: UIWebView, webViewDelegate: UIWebViewDelegate?) {
        super.init()
        
        self.webView = webView
        self.webViewDelegate = webViewDelegate
        webView.delegate = self
        
        injectBridgeScript()
    }
    
    deinit {
        self.webView = nil
        self.webViewDelegate = nil
    }
    
    // 注入js
    private func injectBridgeScript() {
        let path = Bundle.main.path(forResource: "bridge", ofType: "js")
        
        guard let p = path, p.characters.count > 0 else {
            return
        }
        
        do {
            let content = try String(contentsOfFile: p)
            
            let result = self.webView?.stringByEvaluatingJavaScript(from: content)
            print("EvaluatingJavaScript result:%@", result)
        } catch {
            print("String contentsOfFile Error")
        }
    }
    
    // MARK: UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        print("webViewDidStartLoad")

        if let webViewDelegate = webViewDelegate {
            if webViewDelegate.responds(to: #selector(webViewDidStartLoad(_:))) {
                webViewDelegate.webViewDidStartLoad!(webView)
            }
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        print("webViewDidFinishLoad")

        if let webViewDelegate = webViewDelegate {
            if webViewDelegate.responds(to: #selector(webViewDidFinishLoad(_:))) {
                webViewDelegate.webViewDidFinishLoad!(webView)
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        print("didFailLoadWithError, %@", error)
        
        if let webViewDelegate = webViewDelegate {
            if webViewDelegate.responds(to: #selector(webView(_:didFailLoadWithError:))) {
                webViewDelegate.webViewDidFinishLoad!(webView)
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.url?.scheme {
            // 处理自定义scheme，scheme会被自动转成小写，即使js中写成大写
            if scheme == "slwebbridge" {
                print("call native")
                
                // slwebbridge://ui/push?p={a:'xxx', b:1}&cb=callback
                return false
            }
        } else if let webViewDelegate = webViewDelegate, webViewDelegate.responds(to: #selector(webView(_:shouldStartLoadWith:navigationType:))) {
           return webViewDelegate.webView!(webView, shouldStartLoadWith: request, navigationType: navigationType)
        }
        
        return true
    }
}
