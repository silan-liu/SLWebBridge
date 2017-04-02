//
//  ViewController.swift
//  SLWebBridge
//
//  Created by silan on 16/10/11.
//  Copyright © 2016年 summer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: SLWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let uiApi = UIWebAPI()
        
        webView.registerWebAPI("ui", uiApi)
        webView.webViewDelegate = self;
        let path = Bundle.main.path(forResource: "test", ofType: "html")

        guard let p = path, p.characters.count > 0 else {
            return
        }
        
        do {
           let content = try String(contentsOfFile: p)
            webView.loadHTMLString(content, baseURL: Bundle.main.bundleURL)
        } catch {
            print("error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        print("webViewDidStartLoad")
    }
}

