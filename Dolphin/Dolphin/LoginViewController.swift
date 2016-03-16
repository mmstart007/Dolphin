//
//  LoginViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/22/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SSKeychain
import SVProgressHUD

class LoginViewController : UIViewController, UIGestureRecognizerDelegate {
    
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var centerLogoVerticallyConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopSpaceToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginFieldsView: UIView!
    
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpUsernameTextField: UITextField!
    @IBOutlet weak var signUpEmailTextField: UITextField!
    @IBOutlet weak var signUpPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var signUpForDolphinLabel: UILabel!
    
    @IBOutlet weak var signUpFieldView: UIView!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "LoginViewController", bundle: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if navigationController!.viewControllers[0].isKindOfClass(HomeViewController) {
            navigationController?.setViewControllers([self], animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.setFontFamilyForView(self.view, includeSubViews: true)
        setAppearance()
        self.centerLogoVerticallyConstraint.active = false
        self.logoTopSpaceToViewConstraint.constant = UIScreen.mainScreen().bounds.height / 6.0
        self.view.setNeedsUpdateConstraints()
        
        let tapSignUpLabelGesture = UITapGestureRecognizer(target: self, action: "signUpLabelTapped")
        signUpForDolphinLabel.addGestureRecognizer(tapSignUpLabelGesture)
        signUpForDolphinLabel.userInteractionEnabled = true
        
        let tapLoginLabelGesture = UITapGestureRecognizer(target: self, action: "loginLabelTapped")
        loginLabel.addGestureRecognizer(tapLoginLabelGesture)
        loginLabel.userInteractionEnabled = true
        
        let tapViewGesture = UITapGestureRecognizer(target: self, action: "viewTapped")
        self.view.addGestureRecognizer(tapViewGesture)
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
            self.loginFieldsView.hidden = false
        }
    }
    
    func setAppearance() {
        loginEmailTextField.attributedPlaceholder     = NSAttributedString(string: loginEmailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        loginEmailTextField.layer.cornerRadius        = 20
        loginEmailTextField.layer.borderWidth         = 1
        loginEmailTextField.layer.borderColor         = UIColor.whiteColor().CGColor
        
        loginPasswordTextField.attributedPlaceholder  = NSAttributedString(string: loginPasswordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        loginPasswordTextField.layer.cornerRadius     = 20
        loginPasswordTextField.layer.borderWidth      = 1
        loginPasswordTextField.layer.borderColor      = UIColor.whiteColor().CGColor
        
        loginButton.layer.cornerRadius                = 20
        
        signUpUsernameTextField.attributedPlaceholder = NSAttributedString(string: signUpUsernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        signUpUsernameTextField.layer.cornerRadius    = 20
        signUpUsernameTextField.layer.borderWidth     = 1
        signUpUsernameTextField.layer.borderColor     = UIColor.whiteColor().CGColor
        
        signUpEmailTextField.attributedPlaceholder    = NSAttributedString(string: signUpEmailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        signUpEmailTextField.layer.cornerRadius       = 20
        signUpEmailTextField.layer.borderWidth        = 1
        signUpEmailTextField.layer.borderColor        = UIColor.whiteColor().CGColor
        
        signUpPasswordTextField.attributedPlaceholder = NSAttributedString(string: signUpPasswordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        signUpPasswordTextField.layer.cornerRadius    = 20
        signUpPasswordTextField.layer.borderWidth     = 1
        signUpPasswordTextField.layer.borderColor     = UIColor.whiteColor().CGColor
        
        signUpButton.layer.cornerRadius               = 20
    }
    
    func signUpLabelTapped() {
        let fadeAnimation = CATransition()
        fadeAnimation.type = kCATransitionFade
        fadeAnimation.duration = 0.5
        loginFieldsView.layer.addAnimation(fadeAnimation, forKey: nil)
        loginFieldsView.hidden = true
        
        let revealAnimation = CATransition()
        revealAnimation.type = kCATransitionFade
        revealAnimation.duration = 0.5
        signUpFieldView.layer.addAnimation(revealAnimation, forKey: nil)
        signUpFieldView.hidden = false
    }
    
    func loginLabelTapped() {
        let fadeAnimation = CATransition()
        fadeAnimation.type = kCATransitionFade
        fadeAnimation.duration = 0.5
        loginFieldsView.layer.addAnimation(fadeAnimation, forKey: nil)
        loginFieldsView.hidden = false
        
        let revealAnimation = CATransition()
        revealAnimation.type = kCATransitionFade
        revealAnimation.duration = 0.5
        signUpFieldView.layer.addAnimation(revealAnimation, forKey: nil)
        signUpFieldView.hidden = true
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonTouchUpInside(sender: AnyObject) {
        let deviceId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        SVProgressHUD.showWithStatus("Signing")
        networkController.getTokenByDeviceId(deviceId, completionHandler: { (token, error) -> () in
            if error == nil {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.apiToken = token
                // save the user token in keychain
                let newQuery = SSKeychainQuery()
                newQuery.password = token
                newQuery.service  = Constants.KeychainConfig.Service
                newQuery.account  = Constants.KeychainConfig.Account
                newQuery.label    = Constants.KeychainConfig.TokenLabel
                do {
                    try newQuery.save()
                    self.navigationController?.pushViewController((UIApplication.sharedApplication().delegate as! AppDelegate).homeViewController, animated: true)
                }
                catch {
                    // Handle error
                    print("Error: token not saved in keychain")
                }
                SVProgressHUD.dismiss()
                
            } else {
                SVProgressHUD.dismiss()
                let errors: [String]? = error!["errors"] as? [String]
                let alert = UIAlertController(title: "Login failure", message: errors![0], preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    @IBAction func signUpButtonTouchUpInside(sender: AnyObject) {
        var fieldsValidated = true
        var errorTitle: String = ""
        var errorMsg: String = ""
        if !checkValidUsername() {
            fieldsValidated = false
            errorTitle = "Username Error"
            errorMsg = "Username already in use"
        } else if !checkValidMail() {
            fieldsValidated = false
            errorTitle = "Mail Error"
            errorMsg = "Wrong format"
        } else if !checkValidPassword() {
            fieldsValidated = false
            errorTitle = "Password Error"
            errorMsg = "Password should be at least 5 characters long"
        }
        if fieldsValidated {
            
            // fields validated, reigster user
            let deviceId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
            let name: String = ""
            let avatarImage: String = ""
            let email: String = signUpEmailTextField.text!
            let password: String = signUpPasswordTextField.text!
            let user = User(deviceId: deviceId, name: name, imageURL: avatarImage, email: email, password: password)
            SVProgressHUD.showWithStatus("Signing up")
            networkController.registerUser(user, completionHandler: { (token, error) -> () in
                if error == nil {
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.apiToken = token
                    // save the user token in keychain
                    let newQuery = SSKeychainQuery()
                    newQuery.password = token
                    newQuery.service  = Constants.KeychainConfig.Service
                    newQuery.account  = Constants.KeychainConfig.Account
                    newQuery.label    = Constants.KeychainConfig.TokenLabel
                    do {
                        try newQuery.save()
                        let createProfileVC = CreateProfileViewController()
                        self.navigationController?.pushViewController(createProfileVC, animated: true)
                    }
                    catch {
                        // Handle error
                        print("Error: token not saved in keychain")
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    SVProgressHUD.dismiss()
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Signup failure", message: errors![0], preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Auxiliary methods
    
    func checkValidPassword() -> Bool {
        return signUpPasswordTextField.text?.characters.count >= 5
    }
    
    func checkValidUsername() -> Bool {
        return signUpUsernameTextField.text != "test"
    }
    
    func checkValidMail() -> Bool {
        let emailRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(signUpEmailTextField.text)
    }
    
    // MARK: Keyboard handling
    
    func viewTapped() {
        loginEmailTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
        signUpUsernameTextField.resignFirstResponder()
        signUpEmailTextField.resignFirstResponder()
        signUpPasswordTextField.resignFirstResponder()
    }
}
