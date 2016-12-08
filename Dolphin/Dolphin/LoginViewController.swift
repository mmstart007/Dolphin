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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


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
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "LoginViewController", bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if navigationController!.viewControllers[0].isKind(of: HomeViewController.self) {
            navigationController?.setViewControllers([self], animated: true)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapSignUpLabelGesture = UITapGestureRecognizer(target: self, action: #selector(signUpLabelTapped))
        signUpForDolphinLabel.addGestureRecognizer(tapSignUpLabelGesture)
        signUpForDolphinLabel.isUserInteractionEnabled = true
        
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapViewGesture)
        
        self.setAppearance()
        getLoginValuesFromKeychain()
    }
    
    func setAppearance() {
        emailTextField.attributedPlaceholder     = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.white])
        emailTextField.layer.cornerRadius        = emailTextField.frame.height/2.0
        emailTextField.layer.borderWidth         = 1
        emailTextField.layer.borderColor         = UIColor.white.cgColor
        
        passwordTextField.attributedPlaceholder  = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.white])
        passwordTextField.layer.cornerRadius     = passwordTextField.frame.height/2.0
        passwordTextField.layer.borderWidth      = 1
        passwordTextField.layer.borderColor      = UIColor.white.cgColor
        
        loginButton.layer.cornerRadius                = loginButton.frame.height/2.0
    }
    
    func signUpLabelTapped() {
        let signUpView = SignUpViewController()
        self.navigationController?.pushViewController(signUpView, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonTouchUpInside(_ sender: AnyObject) {
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
            SVProgressHUD.show(withStatus: "Signing in")
            networkController.login(userName!, password: password!, completionHandler: { (user, token, userId, error) -> () in
                if error == nil {
                    // Store the apiToken
                    let defaults = UserDefaults.standard
                    defaults.set(token, forKey: "api_token")
                    // Store the currentUserId
                    defaults.set(userId, forKey: "current_user_id")
                    defaults.set(Globals.jsonToNSData((user?.toJson())! as AnyObject), forKey: "current_user")
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.pushViewController((UIApplication.shared.delegate as! AppDelegate).homeViewController, animated: true)
                    SVProgressHUD.dismiss()
                    
                } else {
                    SVProgressHUD.dismiss()
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Login failure", message: errors![0], preferredStyle: .alert)
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
    
    
    // MARK: - Auxiliary methods
    
    func checkValidPassword(_ login: Bool) -> Bool {
        return passwordTextField.text?.characters.count >= 5
    }
    
    func checkValidMail(_ login: Bool) -> Bool {
        let emailRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: emailTextField.text)
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
    
    func saveCredentialsInKeychain(_ email: String, password: String) {
        keychain.set(email, forKey: "email")
        keychain.set(password, forKey: "password")
    }
    
    func resetKeyChain() {
        keychain.clear()
    }
    
    // MARK: - UITextField Delegate.
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var offset = CGFloat(0)
        if Constants.DeviceType.IS_IPHONE_4_OR_LESS || Constants.DeviceType.IS_IPHONE_5 {
            if textField == self.emailTextField {
                offset = 80;
            }
            else if textField == self.passwordTextField {
                offset = 120;
            }
        }
        
        self.mainScrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.mainScrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            self.loginButtonTouchUpInside(self)
        }
        return true
    }
}
