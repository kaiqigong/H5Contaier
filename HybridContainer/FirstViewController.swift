//
//  FirstViewController.swift
//  HybridContainer
//
//  Created by Kaiqi Gong on 2017/9/13.
//  Copyright © 2017年 Kaiqi Gong. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadBtnTouched(_ sender: Any) {
        webView.loadRequest(URLRequest.init(url: URL.init(string: "https://newcrp.shunshunliuxue.com")!))
    }

    @IBAction func loadBtn2Touched(_ sender: Any) {
        webView.loadHTMLString("<a href='myjsbridge://abc.com/home?abc=1'>click2 me</a>", baseURL: URL.init(string: "home"))
    }
}

