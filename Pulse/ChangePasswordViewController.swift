//
//  ChangePasswordViewController.swift
//  Pulse
//
//  Created by Itasari on 11/12/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse
import RKDropdownAlert

class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    var user: PFUser! = PFUser.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Change Password"
        
        UIExtensions.gradientBackgroundFor(view: view)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        UIExtensions.setupViewFor(textField: oldPasswordTextField)
        UIExtensions.setupViewFor(textField: newPasswordTextField)
        UIExtensions.setupViewFor(textField: confirmNewPasswordTextField)
    }

    // MARK: - Actions
    
    @IBAction func onChangePasswordButtonTap(_ sender: UIButton) {
        if validateEntry() {
            //debugPrint("current user username is \(user.username!)")
            
            // Re-login user to confirm they're entering the correct password
            PFUser.logInWithUsername(inBackground: user.username!, password: oldPasswordTextField.text!) { (user: PFUser?, error: Error?) in
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Your old password is incorrect: \(error.localizedDescription)")
                } else {
                    PFUser.current()?.password = self.newPasswordTextField.text!
                    PFUser.current()?.saveInBackground { (success: Bool, error: Error?) in
                        if success {
                            self.ABIShowDropDownAlertWithDelegate(type: AlertTypes.success, title: "Success!", message: "Password change successful", delegate: self)
                        } else {
                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Changing password error: \(error?.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func validateEntry() -> Bool {
        // Check if old password is empty
        guard !((oldPasswordTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Old password field cannot be empty")
            return false
        }
        
        // Check if new password is empty
        guard !((newPasswordTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "New Password field cannot be empty")
            return false
        }
        
        // Check if confirm password is empty
        guard !((confirmNewPasswordTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Confirm New Password field cannot be empty")
            return false
        }
        
        // Check to make sure password == confirm password
        guard newPasswordTextField.text == confirmNewPasswordTextField.text else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "New Password and Confirm New Password must be the same")
            return false
        }
        
        return true
    }
}

// MARK: - RKDropDownAlertDelegate

extension ChangePasswordViewController: RKDropdownAlertDelegate {
    
    func dropdownAlertWasDismissed() -> Bool {
        let _ = self.navigationController?.popViewController(animated: true)
        return true
    }
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
}

