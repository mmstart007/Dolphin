//
//  CreateTextPostViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/5/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import UITextView_Placeholder
import KSTokenView
import SVProgressHUD

class CreateTextPostViewController : DolphinViewController {
    
    let tags: Array<String> = List.names()
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var postToFieldView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var visibilityIconImageView: UIImageView!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var postTagsTextView: KSTokenView!    
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    
    convenience init() {
        self.init(nibName: "CreateTextPostViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDismissButton()
        title = "Write"
        setRightSystemButtonItem(.Done, target: self, action: Selector("donePressed:"))
        let tapVisibilityViewGesture = UITapGestureRecognizer(target: self, action: "goToPrivacySettings")
        postToFieldView.addGestureRecognizer(tapVisibilityViewGesture)
        
        setupFields()
    }
    
    func setupFields() {
        postTextView.placeholderColor = UIColor.lightGrayColor()
        postTextView.placeholder = "Write your moment..."
        
        postTagsTextView.delegate = self
        postTagsTextView.promptText = ""
        postTagsTextView.placeholder = ""
        postTagsTextView.descriptionText = "Tags"
        postTagsTextView.maxTokenLimit = 15 //default is -1 for unlimited number of tokens
        postTagsTextView.style = .Rounded
        postTagsTextView.searchResultSize = CGSize(width: postTagsTextView.frame.width, height: 150)
        postTagsTextView.font = UIFont.systemFontOfSize(14)
        
        parentScrollView = scrollViewContainer
        
    }
    
    // MARK: Privacy Settings
    
    func goToPrivacySettings() {
        let privacySettingsVC = NewPostPrivacySettingsViewController()
        let privacySettingsNavController = UINavigationController(rootViewController: privacySettingsVC)
        presentViewController(privacySettingsNavController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    func donePressed(sender: AnyObject) {
        print("Create post pressed")
        var topics: [Topic] = []
        if postTagsTextView.tokens() != nil {
            let topicsStringArray = postTagsTextView.tokens()
            for t in topicsStringArray! {
                topics.append(Topic(name: t.title))
            }
        }
        let title: String = postTitleTextField.text!
        let text: String = postTextView.text!
        // crate the pod
        let post = Post(user: nil, image: nil, imageData: nil, type: PostType(name: "text"), topics: topics, link: nil, imageUrl: nil, title: title, text: text, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil)
        SVProgressHUD.showWithStatus("Posting")
        networkController.createPost(post, completionHandler: { (post, error) -> () in
            if error == nil {
                
                SVProgressHUD.dismiss()
                if post?.postId != nil {
                    // everything worked ok
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    // there was an error saving the post
                }
                
                
            } else {
                SVProgressHUD.dismiss()
                let errors: [String]? = error!["errors"] as? [String]
                var alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Oops", message: errors![0], preferredStyle: .Alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .Alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    
}

extension CreateTextPostViewController: KSTokenViewDelegate {
    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        var data: Array<String> = []
        for value: String in tags {
            if value.lowercaseString.rangeOfString(string.lowercaseString) != nil {
                data.append(value)
            }
        }
        completion!(results: data)
    }
    
    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
}