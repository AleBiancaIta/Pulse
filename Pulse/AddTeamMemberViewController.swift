//
//  AddTeamMemberViewController.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class AddTeamMemberViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var user: PFUser! = PFUser.current()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    
    @IBAction func onBackButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmitButtonTap(_ sender: UIButton) {
        debugPrint("Submit button tapped")
        
        if validateEntry() {
            prepPersonDictionary(completion: { (dictionary: [String : String]?, error: Error?) in
                if let error = error {
                    debugPrint("Unable to find manager Id, error: \(error.localizedDescription)")
                } else {
                    if let dictionary = dictionary {
                        let person = Person(dictionary: dictionary)
                        Person.savePersonToParse(person: person, withCompletion: { (success: Bool, error: Error?) in
                            if success {
                                self.showAlert(title: "Success", message: "Successfully adding \(person.firstName) to the team list", sender: nil, handler: { (alertAction: UIAlertAction) in
                                    self.dismiss(animated: true, completion: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.Team.addTeamMemberSuccessful), object: self, userInfo: nil)
                                })
                            } else {
                                if let error = error {
                                    self.showAlert(title: "Error", message: "Failed with error: \(error.localizedDescription). Please try again later", sender: nil, handler: nil)
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func validateEntry() -> Bool {
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
    
    fileprivate func prepPersonDictionary(completion: @escaping ([String: String]?, Error?)->()) {
        // If last name is empty, last name = first name
        let lastName = (lastNameTextField.text?.isEmpty)! ? firstNameTextField.text! : lastNameTextField.text!
        let phone = (phoneTextField.text?.isEmpty)! ? "" : phoneTextField.text!
        
        // Get managerId
        getPersonFromParseMatchingCurrentUserId { (person: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("Unable to find person with matching user Id, error: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                if let person = person {
                    var dictionary = [String : String]()
                    // Position Id is hardcoded for now
                    dictionary = [ObjectKeys.Person.firstName: self.firstNameTextField.text!,
                                  ObjectKeys.Person.lastName: lastName,
                                  ObjectKeys.Person.positionId: "2",
                                  ObjectKeys.Person.email: self.emailTextField.text!,
                                  ObjectKeys.Person.phone: phone,
                                  ObjectKeys.Person.managerId: person.objectId!]
                    completion(dictionary, nil)
                }
            }
        }
    }
    
    // THIS FUNCTION SHOULD BE MOVED TO THE "PERSON" CLASS AT SOME POINT
    fileprivate func getPersonFromParseMatchingCurrentUserId(completion: @escaping (PFObject?, Error?) -> ()) {
        let query = PFQuery(className: "Person")
        query.whereKey(ObjectKeys.Person.userId, equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
            if let error = error {
                completion(nil, error)
            } else {
                if let persons = persons {
                    let person = persons[0] //  There should only be 1 match
                    completion(person, nil)
                }
            }
        }
    }
}
