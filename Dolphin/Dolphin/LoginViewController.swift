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

class LoginViewController : UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    let networkController = NetworkController.sharedInstance
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpForDolphinLabel: UILabel!
    
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
        
//        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if navigationController!.viewControllers[0].isKindOfClass(HomeViewController) {
            navigationController?.setViewControllers([self], animated: true)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapSignUpLabelGesture = UITapGestureRecognizer(target: self, action: #selector(signUpLabelTapped))
        signUpForDolphinLabel.addGestureRecognizer(tapSignUpLabelGesture)
        signUpForDolphinLabel.userInteractionEnabled = true
        
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapViewGesture)
        
        self.setAppearance()
        getLoginValuesFromKeychain()
    }
    
    func setAppearance() {
        emailTextField.attributedPlaceholder     = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        emailTextField.layer.cornerRadius        = emailTextField.frame.height/2.0
        emailTextField.layer.borderWidth         = 1
        emailTextField.layer.borderColor         = UIColor.whiteColor().CGColor
        
        passwordTextField.attributedPlaceholder  = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        passwordTextField.layer.cornerRadius     = passwordTextField.frame.height/2.0
        passwordTextField.layer.borderWidth      = 1
        passwordTextField.layer.borderColor      = UIColor.whiteColor().CGColor
        
        loginButton.layer.cornerRadius                = loginButton.frame.height/2.0
    }
    
    func signUpLabelTapped() {
        let signUpView = SignUpViewController()
        self.navigationController?.pushViewController(signUpView, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonTouchUpInside(sender: AnyObject) {
        self.viewTapped()
        
        let userName = emailTextField.text
        let password = passwordTextField.text
        var fieldsValidated = true
        var errorTitle: String = ""
        var errorMsg: String = ""
        
        if !checkValidMail(true) {
            fieldsValidated = false
            errorTitle = Constants.Messages.EmailErrorTitle
            errorMsg = Constants.Messages.EmailErrorMsg
        } else if !checkValidPassword(true) {
            fieldsValidated = false
            errorTitle = Constants.Messages.PasswordErrorTitle
            errorMsg = Constants.Messages.PasswordErrorMsg
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
                    self.navigationController?.navigationBarHidden = false
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
    
    
    // MARK: - Auxiliary methods
    
    func checkValidPassword(login: Bool) -> Bool {
        return passwordTextField.text?.characters.count >= 5
    }
    
    func checkValidMail(login: Bool) -> Bool {
        let emailRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(emailTextField.text)
    }
    
    // MARK: Keyboard handling
    
    func viewTapped() {
        self.view.endEditing(true)
    }
    
    // MARK: - Keychain Handling
    
    func getLoginValuesFromKeychain() {
        let email = keychain.get("email")
        let password = keychain.get("password")
        if email != nil && password != nil {
            emailTextField.text    = email
            passwordTextField.text = password
        }
    }
    
    func saveCredentialsInKeychain(email: String, password: String) {
        keychain.set(email, forKey: "email")
        keychain.set(password, forKey: "password")
    }
    
    func resetKeyChain() {
        keychain.clear()
    }
    
    // MARK: - UITextField Delegate.
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var offset = CGFloat(0)
        if Constants.DeviceType.IS_IPHONE_4_OR_LESS || Constants.DeviceType.IS_IPHONE_5 {
            if textField == self.emailTextField {
                offset = 80;
            }
            else if textField == self.passwordTextField {
                offset = 120;
            }
        }
        
        self.mainScrollView.setContentOffset(CGPointMake(0, offset), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.mainScrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            self.loginButtonTouchUpInside(self)
        }
        return true
    }
}
