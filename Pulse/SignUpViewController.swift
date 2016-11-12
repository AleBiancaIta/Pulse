//
//  SignUpViewController.swift
//  Pulse
//
//  Created by Itasari on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Properties
    
    @IBAction func onSignUpButtonTap(_ sender: UIButton) {
        //self.resignFirstResponder()
        
        // check if textfields are empty
        if (usernameTextField.text?.isEmpty)! || (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
            showAlert(title: "Alert", message: "Username, Email, and Password fields cannot be empty", sender: nil)
        } else {
            // Initialize a user object
            let newUser = PFUser()
            
            // Set user properties
            newUser.username = usernameTextField.text
            newUser.email = emailTextField.text
            newUser.password = passwordTextField.text
            
            // Call sign up function on the object
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                if let error = error {
                    debugPrint("Error in signing up new user: \(error.localizedDescription)")
                } else {
                    debugPrint("User Registered successfully")
                    
                    // Manually segue to login view
                    self.performSegue(withIdentifier: "loginModalSegue", sender: nil)
                }
            }
        }
    }
    
    @IBAction func onCancelButtonTap(_ sender: UIButton) {
        //self.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
}
