//
//  SignUpViewController.swift
//  Dolphin
//
//  Created by Joachim on 8/23/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var rememberUserAndPasswordSwitch: UISwitch!
    @IBOutlet weak var genderSegement: UISegmentedControl!
    @IBOutlet weak var loginLabel: UILabel!
    
    let networkController = NetworkController.sharedInstance

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "SignUpViewController", bundle: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapLoginGesture = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
        self.loginLabel.userInteractionEnabled = true
        self.loginLabel.addGestureRecognizer(tapLoginGesture)
        
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapViewGesture)
        
        self.setAppearance()
    }
    
    func setAppearance() {
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        usernameTextField.layer.cornerRadius    = usernameTextField.frame.height/2.0
        usernameTextField.layer.borderWidth     = 1
        usernameTextField.layer.borderColor     = UIColor.whiteColor().CGColor

        emailTextField.attributedPlaceholder    = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        emailTextField.layer.cornerRadius       = emailTextField.frame.height/2.0
        emailTextField.layer.borderWidth        = 1
        emailTextField.layer.borderColor        = UIColor.whiteColor().CGColor

        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        passwordTextField.layer.cornerRadius    = passwordTextField.frame.height/2.0
        passwordTextField.layer.borderWidth     = 1
        passwordTextField.layer.borderColor     = UIColor.whiteColor().CGColor
        
        signUpButton.layer.cornerRadius               = signUpButton.frame.height/2.0
    }

     @IBAction func signUpButtonTouchUpInside(sender: AnyObject) {
        self.viewTapped()
        
        var fieldsValidated = true
        var errorTitle: String = ""
        var errorMsg: String = ""
        if !checkValidUsername() {
            fieldsValidated = false
            errorTitle = Constants.Messages.UsernameErrortitle
            errorMsg = Constants.Messages.UsernameErrorMsg
        } else if !checkValidMail(false) {
            fieldsValidated = false
            errorTitle = Constants.Messages.EmailErrorTitle
            errorMsg = Constants.Messages.EmailErrorMsg
        } else if !checkValidPassword(false) {
            fieldsValidated = false
            errorTitle = Constants.Messages.PasswordErrorTitle
            errorMsg = Constants.Messages.PasswordErrorMsg
        }
        
        if fieldsValidated {
            // fields validated, reigster user
            let deviceId: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
            let userName: String = usernameTextField.text!
            let avatarImage: String = ""
            let email: String = emailTextField.text!
            let password: String = passwordTextField.text!
            let gender: Int = genderSegement.selectedSegmentIndex
            let user = User(deviceId: deviceId,
                            userName: userName,
                            imageURL: avatarImage,
                            email: email,
                            password: password,
                            gender: gender,
                            city: Globals.currentCity,
                            country: Globals.currentCountry,
                            zip: Globals.currentZip,
                            location: Globals.currentAddress)
            
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

    func checkValidUsername() -> Bool {
        return usernameTextField.text?.characters.count > 0
    }
    
    func checkValidPassword(login: Bool) -> Bool {
        return passwordTextField.text?.characters.count >= 5
    }
    
    func checkValidMail(login: Bool) -> Bool {
        let emailRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(emailTextField.text)
    }
    
    func viewTapped() {
        self.view.endEditing(true)
    }
    
    func loginTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UITextField Delegate.
    

    func textFieldDidBeginEditing(textField: UITextField) {
        var offset = CGFloat(0)
        if Constants.DeviceType.IS_IPHONE_4_OR_LESS || Constants.DeviceType.IS_IPHONE_5 {
            if textField == self.usernameTextField {
                offset = 50;
            }
            else if textField == self.emailTextField {
                offset = 90;
            }
            else if textField == self.passwordTextField {
                offset = 130;
            }
        }
        
        self.mainScrollView.setContentOffset(CGPointMake(0, offset), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.mainScrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.emailTextField.becomeFirstResponder()
        }
        else if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
}
