//
//  WebViewController.swift
//  Dolphin
//
//  Created by Joachim on 5/24/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

class WebViewController: DolphinViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var siteLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        title = siteLink
        
        //Load Web site.
        let url = NSURL(string: siteLink!)
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}