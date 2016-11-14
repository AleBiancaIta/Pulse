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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func onSignUpButtonTap(_ sender: UIButton) {
        //self.resignFirstResponder()
        
        // Verify entry
        if validateEntry() {
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
                    self.showAlert(title: "Error", message: "New user sign up error: \(error.localizedDescription)", sender: nil, handler: nil)
                } else {
                    debugPrint("User registered successfully")
                
                    // Prep the dictionary for the Person object
                    let dictionary = self.prepPersonDictionary()
                    
                    // Create a Person object and save it to Parse
                    let person = Person(dictionary: dictionary)
					person.saveToParse() { (success: Bool, error: Error?) in
                        if success {
                            // Link Person to newUser
                            var query = PFQuery(className: "Person")
                            query.whereKey(ObjectKeys.Person.userId, equalTo: newUser.objectId)
                            query.findObjectsInBackground(block: { (persons: [PFObject]?, error: Error?) in
                                if let persons = persons {
                                    let person = persons[0] // there should only be one match since Id is unique
                                    newUser[ObjectKeys.User.person] = person
                                    newUser.saveInBackground(block: { (success: Bool, error: Error?) in
                                        if let error = error {
                                            print("error saving person: \(error.localizedDescription)")
                                        } else {
                                            print("saved successfully: \(newUser)")
                                            
                                            self.showAlert(title: "Success", message: "Thank you for joining us!", sender: nil) { (alertAction: UIAlertAction) in
                                                
                                                if alertAction.title == "OK" {
                                                    // Run login the background and segue to dashboard vc
                                                    PFUser.logInWithUsername(inBackground: newUser.username!, password: newUser.password!) { (user: PFUser?, error: Error?) in
                                                        if let error = error {
                                                            self.showAlert(title: "Error", message: "User login failed with error: \(error.localizedDescription)", sender: nil, handler: nil)
                                                        } else {
                                                            debugPrint("User logged in successfully after sign up")
                                                            self.segueToDashboardVC()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    })
                                }
                            })
                        } else {
                            debugPrint("Error creating or saving Person object in Parse")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onCancelButtonTap(_ sender: UIButton) {
        //self.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    fileprivate func prepPersonDictionary() -> [String: String] {
        // If last name is empty, last name = first name
        let lastName = (lastNameTextField.text?.isEmpty)! ? firstNameTextField.text! : lastNameTextField.text!
        let phone = (phoneTextField.text?.isEmpty)! ? "" : phoneTextField.text!
        
        var dictionary = [String : String]()
        
        // Position ID is hardcoded for now
        if let userId = PFUser.current()?.objectId {
            dictionary = [ObjectKeys.Person.firstName: firstNameTextField.text!,
                          ObjectKeys.Person.lastName: lastName,
                          ObjectKeys.Person.positionId: "1",
                          ObjectKeys.Person.email: emailTextField.text!,
                          ObjectKeys.Person.phone: phone,
                          ObjectKeys.Person.userId: userId]
        }
        return dictionary
    }
    
    fileprivate func segueToDashboardVC() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let dashboardNavVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.dashboardNavVC)
        self.present(dashboardNavVC, animated: true, completion: nil)
    }
    
    fileprivate func validateEntry() -> Bool {
        // Check if username is empty
        guard !((usernameTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Username field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if password is empty
        guard !((passwordTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if confirm password is empty
        guard !((confirmPasswordTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Confirm password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check to make sure password == confirm password
        guard passwordTextField.text == confirmPasswordTextField.text else {
            showAlert(title: "Error", message: "Password and confirm password must be the same", sender: nil, handler: nil)
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

/* OLD CODE
 if (usernameTextField.text?.isEmpty)! || (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
 showAlert(title: "Alert", message: "Username, Email, and Password fields cannot be empty", sender: nil, handler: nil)
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
 self.showAlert(title: "Error", message: "New user sign up error: \(error.localizedDescription)", sender: nil, handler: nil)
 } else {
 debugPrint("User registered successfully")
 self.showAlert(title: "Success", message: "Thank you for joining us!", sender: nil) { (alertAction: UIAlertAction) in
 
 if alertAction.title == "OK" {
 // Manually segue to login view
 //self.performSegue(withIdentifier: "loginModalSegue", sender: nil)
 
 // TODO: instead of segue-ing to login, run login in the background and if successful, segue to dashboard vc
 // Run login the background and segue to dashboard vc
 PFUser.logInWithUsername(inBackground: newUser.username!, password: newUser.password!) { (user: PFUser?, error: Error?) in
 if let error = error {
 self.showAlert(title: "Error", message: "User login failed with error: \(error.localizedDescription)", sender: nil, handler: nil)
 } else {
 debugPrint("User logged in successfully after sign up")
 
 // Segue to Dashboard view controller
 let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
 let dashboardNavVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.dashboardNavVC)
 self.present(dashboardNavVC, animated: true, completion: nil)
 }
 }
 }
 }
 }
 }
 }*/
