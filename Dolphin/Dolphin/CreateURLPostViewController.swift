//
//  CreateURLPostViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/8/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class CreateURLPostViewController : DolphinViewController, UITextFieldDelegate, UIWebViewDelegate {


    var webView: UIWebView!
    @IBOutlet weak var topBarContainerView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var refreshAndStopLoadingButton: UIButton!
    var isLoadingPage: Bool = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBarContainerView.backgroundColor = UIColor.blueDolphin()
        webView.frame = CGRect(x: 0, y: topBarContainerView.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height - topBarContainerView.frame.size.height)
        view.addSubview(webView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .None
        setBackButton()
        title = "Dolphin"
        
        webView = UIWebView()
        webView.delegate = self
        
        urlTextField.text = "http://apple.com"
        loadRequest("http://apple.com")
        self.webView.scalesPageToFit = true;
        self.webView.contentMode = .ScaleAspectFit;
    }
    
    func loadRequest(urlString: String) {
        let url = NSURL(string: urlString)
        let requestObj = NSMutableURLRequest(URL: url!)
        requestObj.setValue("Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3", forHTTPHeaderField: "User-Agent")
        webView.loadRequest(requestObj)
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var urlText = textField.text!
        if !urlText.hasPrefix("http") {
            urlText = "http://" + urlText        }
        loadRequest(urlText)
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Actions
    
    @IBAction func pinPageButtonTouchUpInside(sender: AnyObject) {
        
        let pageData = NSData(contentsOfURL: (webView.request?.URL!)!)
        let doc = TFHpple(HTMLData: pageData)
        let images = doc.searchWithXPathQuery("//img")
        var imageURLs: [String] = []
        for image: TFHppleElement in (images as? [TFHppleElement])! {
            var imageURL: String? = image.objectForKey("data-src")
            if imageURL == nil || imageURL == "" {
                imageURL = image.objectForKey("src")
            }
            if let url = imageURL where imageURL != "" {
                if !url.hasPrefix("http") {
                    let siteURL = webView.request?.URL
                    if let baseURL = NSURL(string: "/", relativeToURL: siteURL) {
                        imageURL = baseURL.absoluteString.stringByAppendingString(url)
                    }
                }
                imageURLs.append(imageURL!)
            }
        }
        if imageURLs.count > 0 {
            let chooseImageVC = CreateURLPostChooseImageViewController(images: imageURLs)
            navigationController?.pushViewController(chooseImageVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "NO images Obtained from the WebSite", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    
    }
    @IBAction func refreshAndStopLoadingButtonTouchUpInside(sender: AnyObject) {
        if isLoadingPage {
            webView.stopLoading()
            isLoadingPage = false
            setRefreshButton(isLoadingPage)
        } else {
            webView.reload()
        }
    }
    
    func setRefreshButton(isLoading: Bool) {
        if isLoadingPage {
            refreshAndStopLoadingButton.setImage(UIImage(named: "StopLoadingPageIcon"), forState: .Normal)
            refreshAndStopLoadingButton.setImage(UIImage(named: "StopLoadingPageIcon"), forState: .Highlighted)
        } else {
            refreshAndStopLoadingButton.setImage(UIImage(named: "WebPageRefreshIcon"), forState: .Normal)
            refreshAndStopLoadingButton.setImage(UIImage(named: "WebPageRefreshIcon"), forState: .Highlighted)
        }
        
    }
        
    //MARK: WebViewDelegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        print("Started Loading")
        isLoadingPage = true
        setRefreshButton(isLoadingPage)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("Fnished Loading")
        isLoadingPage = false
        setRefreshButton(isLoadingPage)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("Error loading page. The error is: \(error?.description)")
    }
    
}