//
//  FirstViewController.swift
//  HybridContainer
//
//  Created by Kaiqi Gong on 2017/9/13.
//  Copyright © 2017年 Kaiqi Gong. All rights reserved.
//

import UIKit
import SwiftEventBus

class FirstViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SwiftEventBus.onMainThread(self, name: "jscallback") { notification in
            let jsCallback: JSCallback = notification.object as! JSCallback
            print(jsCallback.callbackId)
            print(jsCallback.params)
            self.webView.stringByEvaluatingJavaScript(from: "fromNative('\(jsCallback.callbackId)', '\(jsCallback.params)')")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadBtnTouched(_ sender: Any) {
        webView.loadRequest(URLRequest.init(url: URL.init(string: "https://newcrp.shunshunliuxue.com")!))
    }

    @IBAction func loadBtn2Touched(_ sender: Any) {
        
        webView.loadHTMLString("<a href='myjsbridge://abc.com/home?abc=1'>click2 me</a><script>alert('init script');function fromNative(callbackId, params) {alert('callbackId: ' + callbackId + ', params: ' + params)}</script>", baseURL: URL.init(string: "home"))
    }
}

