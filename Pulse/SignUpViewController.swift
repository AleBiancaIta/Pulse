//
//  SignUpViewController.swift
//  Pulse
//
//  Created by Itasari on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

class SignUpViewController: UIViewController {

    // MARK: - Properties
    
    //@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var profileImageView: PhotoImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    
    var person: Person!
	var photoData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()

		profileImageView.delegate = self
		profileImageView.isEditable = true
    }
    
    // MARK: - Actions
    
    @IBAction func onSignUpButtonTap(_ sender: UIButton) {
        //self.resignFirstResponder()
        
        // Verify entry
        if validateEntry() {
            // Initialize a user object
            let newUser = PFUser()
            
            // Set user properties
            newUser.username = emailTextField.text
            newUser.email = emailTextField.text
            newUser.password = passwordTextField.text
            
            SVProgressHUD.show()
            
            // Call sign up function on the object
            newUser.signUpInBackground { (success: Bool, error: Error?) in
                if let error = error {
                    debugPrint("Error in signing up new user: \(error.localizedDescription)")
                    SVProgressHUD.dismiss()
                    self.ABIShowAlert(title: "Error", message: "New user sign up error: \(error.localizedDescription)", sender: nil, handler: nil)
                } else {
                    debugPrint("User registered successfully")
                
                    // Prep the dictionary for the Person object
                    let dictionary = self.prepPersonDictionary()
                    
                    // Create a Person object and save it to Parse
                    self.person = Person(dictionary: dictionary)
                    self.person.photo = self.photoData

					Person.savePersonToParse(person: self.person) { (success: Bool, error: Error?) in
                        if success {
                            // Link Person to newUser
                            let query = PFQuery(className: "Person")
							let objectId = newUser.objectId! as String
                            query.whereKey(ObjectKeys.Person.userId, equalTo: objectId)
                            query.findObjectsInBackground(block: { (persons: [PFObject]?, error: Error?) in
                                if let persons = persons {
                                    let person = persons[0] // there should only be one match since Id is unique
                                    newUser[ObjectKeys.User.person] = person
                                    newUser.saveInBackground(block: { (success: Bool, error: Error?) in
                                        if let error = error {
                                            print("error saving person: \(error.localizedDescription)")
                                            SVProgressHUD.dismiss()
                                        } else {
                                            print("saved successfully: \(newUser)")
                                            SVProgressHUD.dismiss()
                                            self.ABIShowAlert(title: "Success", message: "Thank you for joining us!", sender: nil) { (alertAction: UIAlertAction) in
                                                
                                                if alertAction.title == "OK" {
                                                    // Run login the background and segue to dashboard vc
                                                    PFUser.logInWithUsername(inBackground: newUser.username!, password: newUser.password!) { (user: PFUser?, error: Error?) in
                                                        if let error = error {
                                                            self.ABIShowAlert(title: "Error", message: "User login failed with error: \(error.localizedDescription)", sender: nil, handler: nil)
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
                            SVProgressHUD.dismiss()
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
    
    // Only call this if validateEntry returns true
    fileprivate func prepPersonDictionary() -> [String: String] {
        // If last name is empty, last name = first name
        let lastName = (lastNameTextField.text?.isEmpty)! ? firstNameTextField.text! : lastNameTextField.text!
        let phone = (phoneTextField.text?.isEmpty)! ? "" : phoneTextField.text!
        
        // let positionId defaults to Individual Contributor (1)
        var positionId = "1"
        let positionDescription = positionTextField.text!
        if let positionIdString = Constants.positions[positionDescription] {
            positionId = positionIdString
        }
        
        var dictionary = [String : String]()
        if let userId = PFUser.current()?.objectId {
            dictionary = [ObjectKeys.Person.firstName: firstNameTextField.text!,
                          ObjectKeys.Person.lastName: lastName,
                          ObjectKeys.Person.positionId: positionId,
                          ObjectKeys.Person.email: emailTextField.text!,
                          ObjectKeys.Person.phone: phone,
                          ObjectKeys.Person.userId: userId,
                          ObjectKeys.Person.companyId: companyNameTextField.text!]
        }
        return dictionary
    }
    
    fileprivate func segueToDashboardVC() {
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let dashboardNavVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.dashboardNavVC)
        self.present(dashboardNavVC, animated: true, completion: nil)
    }
    
    fileprivate func validateEntry() -> Bool {
        // Check if email is empty
        guard !((emailTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "Email field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if password is empty
        guard !((passwordTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "Password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if confirm password is empty
        guard !((confirmPasswordTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "Confirm password field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check to make sure password == confirm password
        guard passwordTextField.text == confirmPasswordTextField.text else {
            ABIShowAlert(title: "Error", message: "Password and confirm password must be the same", sender: nil, handler: nil)
            return false
        }
        
        // Check if first name is empty
        guard !((firstNameTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "First name field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if company name field is empty
        guard !((companyNameTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "Company name field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if position field is empty
        guard !((positionTextField.text?.isEmpty)!) else {
            ABIShowAlert(title: "Error", message: "Position field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if it's a valid email
        guard emailTextField.text!.isValidEmail() else {
            ABIShowAlert(title: "Error", message: "Please enter a valid email", sender: nil, handler: nil)
            return false
        }
        
        // Check if it's a valid phone
        if !(phoneTextField.text?.isEmpty)! && !(phoneTextField.text?.isValidPhone())! {
            ABIShowAlert(title: "Error", message: "Please enter a valid phone", sender: nil, handler: nil)
            return false
        }
        
        return true
    }    
}

extension SignUpViewController : PhotoImageViewDelegate {

	func didSelectImage(sender: PhotoImageView) {
		self.photoData = sender.photoData
	}
}
