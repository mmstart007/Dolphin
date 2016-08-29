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

class CreateTextPostViewController : DolphinViewController, NewPostPrivacySettingsViewControllerDelegate, KSTokenViewDelegate {
    
    let tags: Array<String> = List.names()
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var postToFieldView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var visibilityIconImageView: UIImageView!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var postTagsTextView: KSTokenView!    
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var adjustVisitivilitySettingsIndicator: UIImageView!
    
    // if this var is set, I'm creating a text post from a POD
    var pod: POD?
    var podsToShare: [POD] = []
    var isPresentMode = false
    
    convenience init() {
        self.init(nibName: "CreateTextPostViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        title = "Write"
        setRightSystemButtonItem(.Done, target: self, action: #selector(donePressed(_:)))
        
        setupFields()
    }
    
    func setupFields() {
        postTextView.placeholderColor = UIColor.lightGrayColor()
        postTextView.placeholder = "Write your moment..."
        
        postTagsTextView.delegate         = self
        
        postTagsTextView.promptText       = ""
        postTagsTextView.placeholder      = ""
        postTagsTextView.maxTokenLimit    = 15
        postTagsTextView.style            = .Squared
        postTagsTextView.searchResultSize = CGSize(width: postTagsTextView.frame.width, height: 70)
        postTagsTextView.font             = UIFont.systemFontOfSize(14)
        postTagsTextView.backgroundColor = UIColor.clearColor()

        parentScrollView = scrollViewContainer
        
        var visibilityString = ""
        if podsToShare.count > 0 {
            visibilityString = podsToShare.map({"\($0.name!)"}).joinWithSeparator(", ")
        } else if pod != nil {
            visibilityString = pod!.name!
        } else {
            visibilityString = "Public"
        }
        visibilityLabel.text = visibilityString
        if pod != nil {
            adjustVisitivilitySettingsIndicator.hidden = true
        } else {
            let tapVisibilityViewGesture = UITapGestureRecognizer(target: self, action: #selector(goToPrivacySettings))
            postToFieldView.addGestureRecognizer(tapVisibilityViewGesture)
        }
    }
    
    override func goBackButtonPressed(sender: UIBarButtonItem) {
        if(self.isPresentMode) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Privacy Settings
    
    func goToPrivacySettings() {
        let privacySettingsVC = NewPostPrivacySettingsViewController(selectedPODs: podsToShare, delegate: self)
        navigationController?.pushViewController(privacySettingsVC, animated: true)
    }
    
    // MARK: - Actions
    func donePressed(sender: AnyObject) {
        print("Create post pressed")
        if postTitleTextField.text == nil || postTitleTextField.text == "" || postTextView.text == "" {
            var alert: UIAlertController
            alert = UIAlertController(title: "Error", message: "Please, fill all the fields", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
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
            var podToShare = pod
            if podsToShare.count > 0 {
                podToShare = podsToShare[0]
            }
            
            let post = Post(user: nil, image: nil, imageData: nil, imageWidth: 0, imageHeight: 0, type: PostType(name: "text"), topics: topics, link: nil, imageUrl: nil, title: title, text: text, date: nil, numberOfLikes: nil, numberOfComments: nil, comments: nil, PODId: podToShare?.id)
            SVProgressHUD.showWithStatus("Posting")
            networkController.createPost(post, completionHandler: { (post, error) -> () in
                if error == nil {
                    
                    SVProgressHUD.dismiss()
                    if post?.postId != nil {
                        // everything worked ok
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.CreatedPost, object: nil, userInfo: ["post":post!])
                        if(self.isPresentMode) {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        
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
    
    // MARK: - NewPostPrivacySettingsViewControllerDelegate
    
    func didFinishSettingOptions(selectedPods: [POD]) {
        podsToShare = selectedPods
        var visibilityString = ""
        if podsToShare.count > 0 {
            visibilityString = podsToShare.map({"\($0.name!)"}).joinWithSeparator(", ")
        } else {
            visibilityString = "Public"
        }
        visibilityLabel.text = visibilityString
    }
    
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





