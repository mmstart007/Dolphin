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
import hpple
import SVProgressHUD

class CreateURLPostViewController : DolphinViewController, UITextFieldDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var topBarContainerView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var refreshAndStopLoadingButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var addressView: UIView!
    
    var isLoadingPage: Bool = true

    var urlToLoad: String = ""
    var podId: Int?
    var mPost : Post?
    var comment : PostCommentRequest?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        
        title                           = "Dolphin"
        urlTextField.text               = "http://google.com"
        urlTextField.autocorrectionType = .No
        addTextFieldToKeyboradControlsTextFields(urlTextField)
        
        addressView.layer.masksToBounds = true
        addressView.layer.cornerRadius = 5.0
        
        pinButton.layer.masksToBounds = true
        pinButton.layer.cornerRadius = 5.0
        
        //loadRequest("http://google.com")
        var linkRequest : String = "http://google.com"
        if(mPost != nil)
        {
            linkRequest = (self.mPost?.postLink?.url)!
        }
        loadRequest(linkRequest)
        urlTextField.text               = linkRequest
        self.webView.scalesPageToFit = true;
        self.webView.contentMode = .ScaleAspectFit;
    }
    
    override func goBackButtonPressed(sender: UIBarButtonItem) {
        super.goBackButtonPressed(sender)
        SVProgressHUD.dismiss()
    }
    
    func loadRequest(urlString: String) {
        if webView.loading {
            webView.stopLoading()
        }
        
        SVProgressHUD.showWithMaskType(.None)
        let url = NSURL(string: urlString)
        let requestObj = NSMutableURLRequest(URL: url!)
        requestObj.setValue("Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3", forHTTPHeaderField: "User-Agent")
        webView.loadRequest(requestObj)
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        var urlText = textField.text!
        if Utils.verifyUrl(urlToLoad) {
            if !urlText.hasPrefix("http") {
                urlText = "http://" + urlText
            }
        }
        urlToLoad = urlText.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        
        if !Utils.verifyUrl(urlToLoad) {
            urlToLoad = "http://www.google.com/search?q=".stringByAppendingString(urlToLoad.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        }
        
        urlTextField.text = urlToLoad
        loadRequest(urlToLoad)

        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.endOfDocument)
    }
    
    // MARK: Actions
    
    @IBAction func pinPageButtonTouchUpInside(sender: AnyObject) {
        
        var siteURLString = ""
        if let siteToPinURL = webView.request?.URL {
            siteURLString = siteToPinURL.absoluteString!
        }
        
        SVProgressHUD.showWithMaskType(.None)
        dispatch_async(dispatch_get_main_queue()) {
            let pageData = NSData(contentsOfURL: (self.webView.request?.URL!)!)
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
                        let siteURL = self.webView.request?.URL
                        
                        if !url.hasPrefix("/") {
                            if let baseURL = NSURL(string: "/", relativeToURL: siteURL) {
                                imageURL = baseURL.absoluteString!.stringByAppendingString(url)
                            }
                        }
                        else
                        {
                            if let baseURL = NSURL(string: "/", relativeToURL: siteURL) {
                                let newURL = String(url.characters.dropFirst())
                                imageURL = baseURL.absoluteString!.stringByAppendingString(newURL)
                            }
                        }
                    }
                    imageURLs.append(imageURL!)
                }
            }
            
            SVProgressHUD.dismiss()
            
            if imageURLs.count > 0 {
                let chooseImageVC = CreateURLPostChooseImageViewController(images: imageURLs)
                chooseImageVC.urlLoaded = siteURLString
                chooseImageVC.podId     = self.podId
                self.comment?.url = siteURLString
                chooseImageVC.comment = self.comment
                chooseImageVC.mPost = self.mPost
                self.navigationController?.pushViewController(chooseImageVC, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: "No images obtained from the website", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    @IBAction func refreshAndStopLoadingButtonTouchUpInside(sender: AnyObject) {
        if isLoadingPage {
            webView.stopLoading()
            isLoadingPage = false
            setRefreshButton(isLoadingPage)
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.showWithMaskType(.None)
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
        
        SVProgressHUD.dismiss()
        if let siteURL = webView.request?.URL {
            if siteURL.absoluteString != ""{
                urlTextField.text = siteURL.absoluteString
            }
        }
       
        isLoadingPage = false
        setRefreshButton(isLoadingPage)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        SVProgressHUD.dismiss()
        print("Error loading page. The error is: \(error?.description)")
    }
    
}
