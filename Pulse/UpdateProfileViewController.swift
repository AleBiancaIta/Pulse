//
//  UpdateProfileViewController.swift
//  Pulse
//
//  Created by Itasari on 11/12/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse
import RKDropdownAlert
import SVProgressHUD

class UpdateProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    var user: PFUser! = PFUser.current()
    var person: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        positionLabel.isHidden = true
        
        UIExtensions.gradientBackgroundFor(view: view)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        getUserProfile()
        emailTextField.isUserInteractionEnabled = false
        configureTextFieldDelegate()
        
        UIExtensions.setupViewFor(textField: passwordTextField)
        UIExtensions.setupViewFor(textField: firstNameTextField)
        UIExtensions.setupViewFor(textField: lastNameTextField)
        UIExtensions.setupViewFor(textField: phoneTextField)
        //UIExtensions.setupViewFor(textField: emailTextField) // email not editable
        
        passwordTextField.becomeFirstResponder()
    }

    // MARK: - Actions
    
    @IBAction func onUpdateProfileButtonTap(_ sender: UIButton) {
        if validateEntry() {
            let lastName = (lastNameTextField.text?.isEmpty)! ? firstNameTextField.text : lastNameTextField.text
            let phone = (phoneTextField.text?.isEmpty)! ? "" : phoneTextField.text
            
            SVProgressHUD.show()
            
            PFUser.logInWithUsername(inBackground: user.username!, password: passwordTextField.text!) { (user: PFUser?, error: Error?) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "\(error.localizedDescription)")
                } else {
                    self.person[ObjectKeys.Person.firstName] = self.firstNameTextField.text
                    self.person[ObjectKeys.Person.lastName] = lastName
                    self.person[ObjectKeys.Person.phone] = phone
                    
                    self.person.saveInBackground { (success: Bool, error: Error?) in
                        if success {
                            SVProgressHUD.dismiss()
                            self.ABIShowDropDownAlertWithDelegate(type: AlertTypes.success, title: "Success!", message: "Successfully updated profile", delegate: self)
                            
                            //self.ABIShowAlert(title: "Success", message: "Update profile successful", sender: nil, handler: { (alertAction: UIAlertAction) in
                            //  self.navigationController?.popViewController(animated: true)
                            //})
                        } else {
                            SVProgressHUD.dismiss()
                            if let error = error {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to update user profile with error: \(error.localizedDescription)")
                            } else {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to update user profile with error")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Helpers
    
    fileprivate func getUserProfile() {
        let query = PFQuery(className: "Person")
        query.whereKey(ObjectKeys.Person.userId, equalTo: user.objectId!)
        query.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
            if let error = error {
                debugPrint("Unable to find person associated with current user id, error: \(error.localizedDescription)")
            } else {
                if let persons = persons {
                    if persons.count > 0 {
                        let person = persons[0]
                        self.person = person
                        //debugPrint("after query person is \(self.person)")
                        self.configureTextFields()
                    }
                }
            }
        }
    }
    
    fileprivate func configureTextFields() {
        if person != nil {
            if let firstName = person[ObjectKeys.Person.firstName] as? String {
                firstNameTextField.text = firstName
            }
            if let lastName = person[ObjectKeys.Person.lastName] as? String {
                lastNameTextField.text = lastName
            }
            if let phone = person[ObjectKeys.Person.phone] as? String {
                phoneTextField.text = phone
            }
            if let email = person[ObjectKeys.Person.email] as? String {
                emailTextField.text = email
            }
            if let id = person[ObjectKeys.Person.positionId] as? String {
                positionLabel.text = Constants.positions[id]
            }
            if let company = person[ObjectKeys.Person.companyId] as? String {
                companyLabel.text = company
            }
        }
    }
    
    fileprivate func validateEntry() -> Bool {
        // Check if password is empty
        guard !((passwordTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Password field cannot be empty")
            return false
        }
        
        // Check if first name is empty
        guard !((firstNameTextField.text?.isEmpty)!) else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "First name field cannot be empty")
            return false
        }

        return true
    }
    
    fileprivate func configureTextFieldDelegate() {
        passwordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneTextField.delegate = PhoneTextFieldDelegate.shared
    }
    
    // MARK: - deinit
    
    deinit {
        debugPrint("UpdateProfileVC deinitialized")
    }
}

// MARK: - UITextFieldDelegate

extension UpdateProfileViewController: UITextFieldDelegate {
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

extension UpdateProfileViewController: RKDropdownAlertDelegate {
    
    func dropdownAlertWasDismissed() -> Bool {
        let _ = self.navigationController?.popViewController(animated: true)
        return true
    }
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
}

