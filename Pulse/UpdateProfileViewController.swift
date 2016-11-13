//
//  UpdateProfileViewController.swift
//  Pulse
//
//  Created by Itasari on 11/12/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class UpdateProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var user: PFUser! = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("user contains \(user)")
    }

    // MARK: - Actions
    @IBAction func onUpdateProfileButtonTap(_ sender: UIButton) {
        if validateEntry() {
            if (lastNameTextField.text?.isEmpty)! {
                // last name gets the first name
            }
            
            
        }
    }
    
    
    // MARK: - Helpers
    
    fileprivate func validateEntry() -> Bool {
        // Check if password is empty
        guard !((passwordTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if first name is empty
        guard !((firstNameTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "First name field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if email is empty
        guard !((emailTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Email field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        return true
    }
}
