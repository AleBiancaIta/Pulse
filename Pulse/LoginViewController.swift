//
//  LoginViewController.swift
//  Pulse
//
//  Created by Itasari on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIExtensions.gradientBackgroundFor(view: <#T##UIView#>)
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func onLoginButtonTap(_ sender: UIButton) {
        loginToParse()
    }
    
    @IBAction func onCancelButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    @IBAction func onForgetPasswordButtonTap(_ sender: UIButton) {
    //        let forgetVC = ForgetPasswordViewController(nibName: "ForgetPasswordViewController", bundle: nil)
    //        self.present(forgetVC, animated: true, completion: nil)
    //    }
    
    fileprivate func loginToParse() {
        if (usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
            ABIShowAlert(title: "Alert", message: "Username and password fields cannot be empty", sender: nil, handler: nil)
        } else {
            if let username = usernameTextField.text, let password = passwordTextField.text {
                PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
                    if let error = error {
                        self.ABIShowAlert(title: "Error", message: "User login failed with error: \(error.localizedDescription)", sender: nil, handler: nil)
                    } else {
                        debugPrint("User logged in successfully")
                        // Segue to Dashboard view controller
                        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                        let dashboardNavVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.dashboardNavVC)
                        self.present(dashboardNavVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.becomeFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        loginToParse()
        return true
    }
}
