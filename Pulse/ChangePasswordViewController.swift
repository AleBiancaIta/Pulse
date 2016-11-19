//
//  ChangePasswordViewController.swift
//  Pulse
//
//  Created by Itasari on 11/12/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    var user: PFUser! = PFUser.current()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    
    @IBAction func onChangePasswordButtonTap(_ sender: UIButton) {
        if validateEntry() {
            debugPrint("current user username is \(user.username!)")
            
            // Re-login user to confirm they're entering the correct password
            PFUser.logInWithUsername(inBackground: user.username!, password: oldPasswordTextField.text!) { (user: PFUser?, error: Error?) in
                if let error = error {
                    self.ABIShowAlert(title: "Error", message: "Your old password is incorrect: \(error.localizedDescription)", sender: nil, handler: nil)
                } else {
                    PFUser.current()?.password = self.newPasswordTextField.text!
                    PFUser.current()?.saveInBackground(block: { (success: Bool, error: Error?) in
                        if success {
                            self.ABIShowAlert(title: "Success", message: "Password change successful", sender: nil, handler: { (alertAction: UIAlertAction) in
                                let _ = self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            self.ABIShowAlert(title: "Error", message: "Changing password error: \(error?.localizedDescription)", sender: nil, handler: nil)
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func validateEntry() -> Bool {
        // Check if old password is empty
        guard !((oldPasswordTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "Old password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if new password is empty
        guard !((newPasswordTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "New Password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if confirm password is empty
        guard !((confirmNewPasswordTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "Confirm new password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check to make sure password == confirm password
        guard newPasswordTextField.text == confirmNewPasswordTextField.text else {
            ABIShowAlert(title: "Error", message: "New Password and confirm new password must be the same", sender: nil, handler: nil)
            return false
        }
        
        return true
    }
}
