//
//  LoginViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 12/22/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import KeychainSwift

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
    
    @IBOutlet weak var rememberUserAndPasswordSwitch: UISwitch!
    
    let keychain = KeychainSwift()
    
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
        
        loginEmailTextField.keyboardType           = .EmailAddress
        signUpEmailTextField.keyboardType          = .EmailAddress
        signUpEmailTextField.autocorrectionType    = .No
        loginEmailTextField.autocorrectionType     = .No
        signUpUsernameTextField.autocorrectionType = .No
        
        getLoginValuesFromKeychain()
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
        let userName = loginEmailTextField.text
        let password = loginPasswordTextField.text
        var fieldsValidated = true
        var errorTitle: String = ""
        var errorMsg: String = ""
        
        if !checkValidMail(true) {
            fieldsValidated = false
            errorTitle = "Email error"
            errorMsg = "Wrong format"
        } else if !checkValidPassword(true) {
            fieldsValidated = false
            errorTitle = "Password error"
            errorMsg = "Password should be at least 5 characters long"
        }
        if fieldsValidated {
            SVProgressHUD.showWithStatus("Signing in")
            networkController.login(userName!, password: password!, completionHandler: { (user, token, userId, error) -> () in
                if error == nil {
                    // Store the apiToken
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(token, forKey: "api_token")
                    // Store the currentUserId
                    defaults.setObject(userId, forKey: "current_user_id")
                    defaults.setObject(Globals.jsonToNSData((user?.toJson())!), forKey: "current_user")
                    self.navigationController?.pushViewController((UIApplication.sharedApplication().delegate as! AppDelegate).homeViewController, animated: true)
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
        } else {
            let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func signUpButtonTouchUpInside(sender: AnyObject) {
        var fieldsValidated = true
        var errorTitle: String = ""
        var errorMsg: String = ""
        if !checkValidUsername() {
            fieldsValidated = false
            errorTitle = "Username error"
            errorMsg = "Username empty"
        } else if !checkValidMail(false) {
            fieldsValidated = false
            errorTitle = "Email error"
            errorMsg = "Wrong format"
        } else if !checkValidPassword(false) {
            fieldsValidated = false
            errorTitle = "Password error"
            errorMsg = "Password should be at least 5 characters long"
        }
        if fieldsValidated {
            
            // fields validated, reigster user
            let deviceId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
            let userName: String = signUpUsernameTextField.text!
            let avatarImage: String = ""
            let email: String = signUpEmailTextField.text!
            let password: String = signUpPasswordTextField.text!
            let user = User(deviceId: deviceId, userName: userName, imageURL: avatarImage, email: email, password: password)
            SVProgressHUD.showWithStatus("Signing up")
            networkController.registerUser(user, completionHandler: { (user, token, userId, error) -> () in
                if error == nil {
                    
                    // Store the apiToken
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(token, forKey: "api_token")
                    // Store the currentUserId
                    defaults.setObject(userId, forKey: "current_user_id")
                    defaults.setObject(Globals.jsonToNSData((user?.toJson())!), forKey: "current_user")
                    
                    let createProfileVC = CreateProfileViewController()
                    self.navigationController?.pushViewController(createProfileVC, animated: true)
                    
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
    
    func checkValidPassword(login: Bool) -> Bool {
        if login {
            return loginPasswordTextField.text?.characters.count >= 5
        } else {
            return signUpPasswordTextField.text?.characters.count >= 5
        }
    }
    
    func checkValidUsername() -> Bool {
        return signUpUsernameTextField.text?.characters.count > 0
    }
    
    func checkValidMail(login: Bool) -> Bool {
        let emailRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if login {
            return emailTest.evaluateWithObject(loginEmailTextField.text)
        } else {
            return emailTest.evaluateWithObject(signUpEmailTextField.text)
        }
    }
    
    // MARK: Keyboard handling
    
    func viewTapped() {
        loginEmailTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
        signUpUsernameTextField.resignFirstResponder()
        signUpEmailTextField.resignFirstResponder()
        signUpPasswordTextField.resignFirstResponder()
    }
    
    // MARK: - Keychain Handling
    
    func getLoginValuesFromKeychain() {
        let email = keychain.get("email")
        let password = keychain.get("password")
        if email != nil && password != nil {
            loginEmailTextField.text    = email
            loginPasswordTextField.text = password
        }
    }
    
    func saveCredentialsInKeychain(email: String, password: String) {
        keychain.set(email, forKey: "email")
        keychain.set(password, forKey: "password")
    }
    
    func resetKeyChain() {
        keychain.clear()
    }
}
