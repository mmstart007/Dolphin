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

class CreateTextPostViewController : DolphinViewController {
    
    let tags: Array<String> = List.names()
    
    @IBOutlet weak var postToFieldView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var visibilityIconImageView: UIImageView!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var postTagsTextView: KSTokenView!
    
    convenience init() {
        self.init(nibName: "CreateTextPostViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDismissButton()
        title = "Write"
        setRightSystemButtonItem(.Done, target: self, action: nil)
        let tapVisibilityViewGesture = UITapGestureRecognizer(target: self, action: "goToPrivacySettings")
        postToFieldView.addGestureRecognizer(tapVisibilityViewGesture)
        
        setupFields()
    }
    
    func setupFields() {
        postTextView.placeholderColor = UIColor.lightGrayColor()
        postTextView.placeholder = "Write your moment..."
        
        postTagsTextView.delegate = self
        postTagsTextView.promptText = "Tags: "
        postTagsTextView.placeholder = "Type to search"
        postTagsTextView.descriptionText = "Languages"
        postTagsTextView.maxTokenLimit = 5 //default is -1 for unlimited number of tokens
        postTagsTextView.style = .Squared
        
//        /// default is true. token can be deleted with keyboard 'x' button
//        tokenView.shouldDeleteTokenOnBackspace = true
//        
//        /// Only works for iPhone now, not iPad devices. default is false. If true, search results are hidden when one of them is selected
//        tokenView.shouldHideSearchResultsOnSelect = false
//        
//        /// default is false. If true, already added token still appears in search results
//        tokenView.shouldDisplayAlreadyTokenized = false
//        
//        /// default is ture. Sorts the search results alphabatically according to title provided by tokenView(_:displayTitleForObject) delegate
//        tokenView.shouldSortResultsAlphabatically = true
//        
//        /// default is true. If false, token can only be added from picking search results. All the text input would be ignored
//        tokenView.shouldAddTokenFromTextInput = true
//        
//        /// default is 1
//        tokenView.minimumCharactersToSearch = 1
//        
//        /// Default is (TokenViewWidth, 200)
//        tokenView.searchResultSize = CGSize(width: tokenView.frame.width, height: 120)
//        
//        /// Default is whiteColor()
//        tokenView.searchResultBackgroundColor = UIColor.whiteColor()
//        
//        /// default is UIColor.blueColor()
//        tokenView.activityIndicatorColor = UIColor.blueColor()
//        
//        /// default is 120.0. After maximum limit is reached, tokens starts scrolling vertically
//        tokenView.maximumHeight = 120.0
//        
//        /// default is UIColor.grayColor()
//        tokenView.cursorColor = UIColor.grayColor()
//        
//        /// default is 10.0. Horizontal padding of title
//        tokenView.paddingX = 10.0
//        
//        /// default is 2.0. Vertical padding of title
//        tokenView.paddingY = 2.0
//        
//        /// default is 5.0. Horizontal margin between tokens
//        tokenView.marginX = 5.0
//        
//        /// default is 5.0. Vertical margin between tokens
//        tokenView.marginY = 5.0
//        
//        /// default is UIFont.systemFontOfSize(16)
//        tokenView.font = UIFont.systemFontOfSize(16)
//        
//        /// default is 50.0. Caret moves to new line if input width is less than this value
//        tokenView.minWidthForInput = 100.0
//        
//        /// default is ", ". Used to seperate titles when untoknized
//        tokenView.seperatorText = ", "
//        
//        /// default is 0.25.
//        tokenView.animateDuration = 0.25
//        
//        /// default is true. When resignFirstResponder is called tokens are removed and description is displayed.
//        tokenView.removesTokensOnEndEditing = true
//        
//        /// Default is "selections"
//        tokenView.descriptionText = "Languages"
//        
//        /// set -1 for unlimited.
//        tokenView.maxTokenLimit = 5
//        
//        /// default is "To: "
//        tokenView.promptText = "Top 5: "
//        
//        /// default is true. If false, cannot be edited
//        tokenView.editable = true
//        
//        /// default is nil
//        tokenView.placeholder = "Type to search"
//        
//        /// default is .Rounded, creates rounded corner
//        tokenView.style = .Squared
//        
//        /// default is .Vertical, following creates horizontal scrolling direction
//        tokenView.direction = .Horizontal
//        
//        /// An array of string values. Default values are "." and ",". Token is created with typed text, when user press any of the character mentioned in this Array
//        tokenView.tokenizingCharacters = [","]
        
    }
    
    // MARK: Privacy Settings
    
    func goToPrivacySettings() {
        let privacySettingsVC = NewPostPrivacySettingsViewController()
        let privacySettingsNavController = UINavigationController(rootViewController: privacySettingsVC)
        presentViewController(privacySettingsNavController, animated: true, completion: nil)
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