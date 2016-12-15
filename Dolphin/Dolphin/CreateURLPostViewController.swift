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
        urlTextField.autocorrectionType = .no
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
        self.webView.contentMode = .scaleAspectFit;
    }
    
    override func goBackButtonPressed(_ sender: UIBarButtonItem) {
        super.goBackButtonPressed(sender)
        SVProgressHUD.dismiss()
    }
    
    func loadRequest(_ urlString: String) {
        if webView.isLoading {
            webView.stopLoading()
        }
        
        SVProgressHUD.show(with: .none)
        let url = URL(string: urlString)
        let requestObj = NSMutableURLRequest(url: url!)
        requestObj.setValue("Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3", forHTTPHeaderField: "User-Agent")
        webView.loadRequest(requestObj as URLRequest)
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        var urlText = textField.text!
        if Utils.verifyUrl(urlToLoad) {
            if !urlText.hasPrefix("http") {
                urlText = "http://" + urlText
            }
        }
        urlToLoad = urlText.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        
        if !Utils.verifyUrl(urlToLoad) {
            urlToLoad = "http://www.google.com/search?q=" + urlToLoad.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        
        urlTextField.text = urlToLoad
        loadRequest(urlToLoad)

        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    // MARK: Actions
    
    @IBAction func pinPageButtonTouchUpInside(_ sender: AnyObject) {
        
        var siteURLString = ""
        if let siteToPinURL = webView.request?.url {
            siteURLString = siteToPinURL.absoluteString
        }
        
        SVProgressHUD.show(with: .none)
        DispatchQueue.main.async {
            let pageData = try? Data(contentsOf: (self.webView.request?.url!)!)
            let doc = TFHpple(htmlData: pageData)
            let images = doc?.search(withXPathQuery: "//img")
            var imageURLs: [String] = []
            for image: TFHppleElement in (images as? [TFHppleElement])! {
                var imageURL: String? = image.object(forKey: "data-src")
                if imageURL == nil || imageURL == "" {
                    imageURL = image.object(forKey: "src")
                }
                if let url = imageURL, imageURL != "" {
                    if !url.hasPrefix("http") {
                        let siteURL = self.webView.request?.url
                        
                        if !url.hasPrefix("/") {
                            if let baseURL = URL(string: "/", relativeTo: siteURL) {
                                imageURL = baseURL.absoluteString + url
                            }
                        }
                        else
                        {
                            if let baseURL = URL(string: "/", relativeTo: siteURL) {
                                let newURL = String(url.characters.dropFirst())
                                imageURL = baseURL.absoluteString + newURL
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
                let alert = UIAlertController(title: "Error", message: "No images obtained from the website", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @IBAction func refreshAndStopLoadingButtonTouchUpInside(_ sender: AnyObject) {
        if isLoadingPage {
            webView.stopLoading()
            isLoadingPage = false
            setRefreshButton(isLoadingPage)
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show(with: .none)
            webView.reload()
        }
    }
    
    func setRefreshButton(_ isLoading: Bool) {
        if isLoadingPage {
            refreshAndStopLoadingButton.setImage(UIImage(named: "StopLoadingPageIcon"), for: UIControlState())
            refreshAndStopLoadingButton.setImage(UIImage(named: "StopLoadingPageIcon"), for: .highlighted)
        } else {
            refreshAndStopLoadingButton.setImage(UIImage(named: "WebPageRefreshIcon"), for: UIControlState())
            refreshAndStopLoadingButton.setImage(UIImage(named: "WebPageRefreshIcon"), for: .highlighted)
        }
        
    }
        
    //MARK: WebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Started Loading")
        SVProgressHUD.show()
        isLoadingPage = true
        setRefreshButton(isLoadingPage)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Fnished Loading")
        
        SVProgressHUD.dismiss()
        if let siteURL = webView.request?.url {
            if siteURL.absoluteString != ""{
                urlTextField.text = siteURL.absoluteString
            }
        }
       
        isLoadingPage = false
        setRefreshButton(isLoadingPage)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SVProgressHUD.dismiss()
        print("Error loading page. The error is: \(error.localizedDescription)")
    }
    
}
