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
    var person: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfile()
    }

    // MARK: - Actions
    @IBAction func onUpdateProfileButtonTap(_ sender: UIButton) {
        if validateEntry() {
            let lastName = (lastNameTextField.text?.isEmpty)! ? firstNameTextField.text : lastNameTextField.text
            let phone = (phoneTextField.text?.isEmpty)! ? "" : phoneTextField.text
            
            PFUser.logInWithUsername(inBackground: user.username!, password: passwordTextField.text!) { (user: PFUser?, error: Error?) in
                if let error = error {
                    self.showAlert(title: "Error", message: "Your password is incorrect: \(error.localizedDescription)", sender: nil, handler: nil)
                } else {
                    self.person[ObjectKeys.Person.firstName] = self.firstNameTextField.text
                    self.person[ObjectKeys.Person.lastName] = lastName
                    self.person[ObjectKeys.Person.phone] = phone
                    self.person[ObjectKeys.Person.email] =  self.emailTextField.text
                    
                    self.person.saveInBackground(block: { (success: Bool, error: Error?) in
                        if success {
                            self.showAlert(title: "Success", message: "Update profile successful", sender: nil, handler: { (alertAction: UIAlertAction) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        } else {
                            self.showAlert(title: "Error", message: "Unable to update user profile with error: \(error?.localizedDescription)", sender: nil, handler: nil)
                        }
                    })
                }
            }
        }
    }
    
    
    // MARK: - Helpers
    
    fileprivate func getUserProfile() {
        var query = PFQuery(className: "Person")
        query.whereKey(ObjectKeys.Person.userId, equalTo: user.objectId!)
        query.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
            if let error = error {
                debugPrint("Unable to find person associated with current user id, error: \(error.localizedDescription)")
            } else {
                if let persons = persons {
                    if persons.count > 0 {
                        let person = persons[0]
                        self.person = person
                        debugPrint("after query person is \(self.person)")
                        self.configureTextFields()
                    }
                }
            }
        }
    }
    
    fileprivate func configureTextFields() {
        if person != nil {
            firstNameTextField.text = person[ObjectKeys.Person.firstName] as! String
            lastNameTextField.text = person[ObjectKeys.Person.lastName] as! String
            phoneTextField.text = person[ObjectKeys.Person.phone] as! String
            emailTextField.text = person[ObjectKeys.Person.email] as! String
        }
    }
    
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
