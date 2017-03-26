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
    private var apiDict: [String:WebAPIProtocol];
    
    convenience init(webView: UIWebView) {
        self.init(webView: webView, webViewDelegate: nil)
    }
    
    init(webView: UIWebView, webViewDelegate: UIWebViewDelegate?) {
        apiDict = [String:WebAPIProtocol]();

        super.init()
        
        self.webView = webView
        self.webViewDelegate = webViewDelegate
        webView.delegate = self
        
        // 注入js
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
            print("EvaluatingJavaScript result:\(result)");
        } catch {
            print("String contentsOfFile Error")
        }
    }
    
    //MARK: get webAPI
    func webAPI(_ module: String) -> WebAPIProtocol? {
        let obj = apiDict[module]
        return obj
    }
    
    //MARK: Register API
    func registerWebAPI(_ module: String, _ api: WebAPIProtocol) {
        apiDict[module] = api
    }
    
    func unregisterWebAPI(_ module: String) {
        apiDict.removeValue(forKey: module);
    }
    
    //MARK: handle web event
    func handleWebEvent(_ url: URL?, webView: UIWebView) -> Bool {
        guard var url = url else {
            return false
        }
        
        // 模块
        let host = url.host
        guard let module = host, module.characters.count > 0 else {
            return false
        }
        
        // 方法
        var name: String?
        
        let pathComponents = url.pathComponents
        if pathComponents.count == 2 {
            name = pathComponents[1]
        }
        
        guard let method = name, method.characters.count > 0 else {
            return false
        }
        
        //处理参数
        var dict: [String: AnyObject]?
        
        let jsonString = url.objectForKey("p")
        if let jsonString = jsonString {
            let data = jsonString.data(using: .utf8)
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
                    dict = jsonObject
                    
                    if let jsonObject = jsonObject {
                        print("dict:\(jsonObject)")
                    }
                    
                } catch {
                    print("parse json error")
                }
            }
        }
        
        var callback: SLCallback?
        
        //cb，在js端是个id，根据id找到对应的function
        let callbackId = url.objectForKey("cb")
        if let callbackId = callbackId {
            // 生成callback
            callback = { result in
                guard let result = result else {
                    return
                }
                
                // 将result-->string
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
                    
                    var jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
                    
                    jsonString = jsonString ?? "{}"
                    
                    let script = String(format: "SLWebBridge.invokeWebMethod(%@,%@);", callbackId, jsonString!)
                    
                    print("\(jsonString)")
                    
                    print("\(script)")
                    
                    webView.stringByEvaluatingJavaScript(from: script)
                    
                } catch {
                    print("json to string error")
                }
            }
        }
        
        let webApi = webAPI(module)
        if let webApi = webApi {
            webApi.callNativeMethod(name: method, parameter: dict, callback: callback)
        }
        
        return false
    }

    //MARK: UIWebViewDelegate
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
                
                // slwebbridge://ui/push?p={\"a\":'xxx', \"b\":1}&cb=2344
                return handleWebEvent(request.url, webView: webView)
            }
        } else if let webViewDelegate = webViewDelegate, webViewDelegate.responds(to: #selector(webView(_:shouldStartLoadWith:navigationType:))) {
           return webViewDelegate.webView!(webView, shouldStartLoadWith: request, navigationType: navigationType)
        }
        
        return true
    }
}
