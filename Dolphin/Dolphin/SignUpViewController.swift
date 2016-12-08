//
//  SignUpViewController.swift
//  Dolphin
//
//  Created by Joachim on 8/23/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


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
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "SignUpViewController", bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapLoginGesture = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
        self.loginLabel.isUserInteractionEnabled = true
        self.loginLabel.addGestureRecognizer(tapLoginGesture)
        
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapViewGesture)
        
        self.setAppearance()
    }
    
    func setAppearance() {
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.white])
        usernameTextField.layer.cornerRadius    = usernameTextField.frame.height/2.0
        usernameTextField.layer.borderWidth     = 1
        usernameTextField.layer.borderColor     = UIColor.white.cgColor

        emailTextField.attributedPlaceholder    = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.white])
        emailTextField.layer.cornerRadius       = emailTextField.frame.height/2.0
        emailTextField.layer.borderWidth        = 1
        emailTextField.layer.borderColor        = UIColor.white.cgColor

        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.white])
        passwordTextField.layer.cornerRadius    = passwordTextField.frame.height/2.0
        passwordTextField.layer.borderWidth     = 1
        passwordTextField.layer.borderColor     = UIColor.white.cgColor
        
        signUpButton.layer.cornerRadius               = signUpButton.frame.height/2.0
    }

     @IBAction func signUpButtonTouchUpInside(_ sender: AnyObject) {
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
            let deviceId: String = UIDevice.current.identifierForVendor!.uuidString
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
            
            SVProgressHUD.show(withStatus: "Signing up")
            networkController.registerUser(user, completionHandler: { (user, token, userId, error) -> () in
                if error == nil {
                    // Store the apiToken
                    let defaults = UserDefaults.standard
                    defaults.set(token, forKey: "api_token")
                    
                    // Store the currentUserId
                    defaults.set(userId, forKey: "current_user_id")
                    defaults.set(Globals.jsonToNSData((user?.toJson())! as AnyObject), forKey: "current_user")
                    
                    let createProfileVC = CreateProfileViewController()
                    self.navigationController?.pushViewController(createProfileVC, animated: true)
                    
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Signup failure", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }

    func checkValidUsername() -> Bool {
        return usernameTextField.text?.characters.count > 0
    }
    
    func checkValidPassword(_ login: Bool) -> Bool {
        return passwordTextField.text?.characters.count >= 5
    }
    
    func checkValidMail(_ login: Bool) -> Bool {
        let emailRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: emailTextField.text)
    }
    
    func viewTapped() {
        self.view.endEditing(true)
    }
    
    func loginTapped() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UITextField Delegate.
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
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
        
        self.mainScrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.mainScrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
