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
import RKDropdownAlert

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var scrollView: UIScrollView!
	@IBOutlet weak var profileImageView: PhotoImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var positionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var signUpButton: UIButton!
    
    var person: Person!
	var photoData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIExtensions.gradientBackgroundFor(view: scrollView)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        positionSegmentedControl.layer.cornerRadius = 5

        configureTextFieldDelegate()
        signUpButton.isEnabled = true
        
		profileImageView.delegate = self
		profileImageView.isEditable = true
        
        scrollView.contentSize = UIScreen.main.bounds.size
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelButtonTap(_:)))
        
        UIExtensions.setupViewFor(textField: emailTextField)
        UIExtensions.setupViewFor(textField: passwordTextField)
        UIExtensions.setupViewFor(textField: confirmPasswordTextField)
        UIExtensions.setupViewFor(textField: firstNameTextField)
        UIExtensions.setupViewFor(textField: lastNameTextField)
        UIExtensions.setupViewFor(textField: phoneTextField)
        UIExtensions.setupViewFor(textField: companyNameTextField)
    }
    
    // MARK: - Actions
    
    @IBAction func onSignUpButtonTap(_ sender: UIButton) {
        signUpButton.isEnabled = false
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
                    self.signUpButton.isEnabled = true
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "New user sign up error: \(error.localizedDescription)")
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
                                    newUser.saveInBackground { (success: Bool, error: Error?) in
                                        if let error = error {
                                            print("error saving person: \(error.localizedDescription)")
                                            SVProgressHUD.dismiss()
                                            self.signUpButton.isEnabled = true
                                        } else {
                                            print("saved successfully: \(newUser)")
                                            SVProgressHUD.dismiss()
                                            self.signUpButton.isEnabled = true
                                            self.ABIShowDropDownAlertWithDelegate(type: AlertTypes.success, title: "Success!", message: "Thank you for joining us!", delegate: self)
                                        }
                                    }
                                }
                            })
                        } else {
                            debugPrint("Error creating or saving Person object in Parse")
                            SVProgressHUD.dismiss()
                            self.signUpButton.isEnabled = true
                        }
                    }
                }
            }
        } else {
            signUpButton.isEnabled = true
        }
    }
    
    @IBAction func onCancelButtonTap(_ sender: UIButton) {
        //self.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Helpers
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //scrollView.frame.size.height = UIScreen.main.bounds.size.height - keyboardSize.height - 64
            if scrollView.frame.origin.y != 0 {
                scrollView.frame.origin.y = 0
            }
            scrollView.frame.origin.y -= keyboardSize.height - 64
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //scrollView.frame.size.height = UIScreen.main.bounds.size.height - 64
        scrollView.frame.origin.y = 64
    }
    
    // Only call this if validateEntry returns true
    fileprivate func prepPersonDictionary() -> [String: String] {
        // If last name is empty, last name = first name
        let lastName = (lastNameTextField.text?.isEmpty)! ? firstNameTextField.text! : lastNameTextField.text!
        let phone = (phoneTextField.text?.isEmpty)! ? "" : phoneTextField.text!
        
        /*
        // let positionId defaults to Individual Contributor (1)
        var positionId = "1"
        let positionDescription = positionTextField.text!
        if let positionIdString = Constants.positions[positionDescription] {
            positionId = positionIdString
        }*/
        
        // TODO: Change this to use the Constants file instead of hardcoded
        let offset = 2
        let positionId = "\(positionSegmentedControl.selectedSegmentIndex + offset)"
        
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
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Email field cannot be empty")
            return false
        }
        
        // Check if password is empty
        guard !((passwordTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Password field cannot be empty")
            return false
        }
        
        // Check if confirm password is empty
        guard !((confirmPasswordTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Confirm password field cannot be empty")
            return false
        }
        
        // Check to make sure password == confirm password
        guard passwordTextField.text == confirmPasswordTextField.text else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Password and confirm password must be the same")
            return false
        }
        
        // Check if first name is empty
        guard !((firstNameTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "First name field cannot be empty")
            return false
        }
        
        // Check if company name field is empty
        guard !((companyNameTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Company name field cannot be empty")
            return false
        }
        
        // Check if it's a valid email
        guard emailTextField.text!.isValidEmail() else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Please enter a valid email")
            return false
        }

        return true
    }
    
    fileprivate func configureTextFieldDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneTextField.delegate = PhoneTextFieldDelegate.shared
        companyNameTextField.delegate = self
    }
}

extension SignUpViewController : PhotoImageViewDelegate {

	func didSelectImage(sender: PhotoImageView) {
		self.photoData = sender.photoData
	}
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.becomeFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

// MARK: - RKDropDownAlertDelegate

extension SignUpViewController: RKDropdownAlertDelegate {
    
    func dropdownAlertWasDismissed() -> Bool {
        self.segueToDashboardVC()
        return true
    }
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
}

