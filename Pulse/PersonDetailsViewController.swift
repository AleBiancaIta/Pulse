//
//  PersonDetailsViewController.swift
//  Pulse
//
//  Created by Alejandra Negrete on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import RKDropdownAlert

class PersonDetailsViewController: UIViewController {

	@IBOutlet weak var photoImageView: PhotoImageView!
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var phoneTextField: UITextField!
	@IBOutlet weak var callButton: UIButton!
	@IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var positionDescTextField: UITextField!
    @IBOutlet weak var contractEndTextField: UITextField!

	var photoData: Data?
	var person: Person?
    var personPFObject: PFObject?
	var personInfoParentViewController: Person2DetailsViewController?

	// MARK: - View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
        personInfoParentViewController?.navigationItem.title = "New Team Member"

		initPerson()
		initImage()
		initViews()
	}

	// MARK: - Initializations

	func initImage() {
		photoImageView.delegate = self
		photoImageView.isEditable = true
	}

	func initPerson() {

		if let pfObject = personPFObject {

			let firstName =  pfObject[ObjectKeys.Person.firstName] as! String
			let lastName = pfObject[ObjectKeys.Person.lastName] as! String
            let positionDesc = pfObject[ObjectKeys.Person.positionDesc] as? String
            let contractEndDate = pfObject[ObjectKeys.Person.contractEndDate] as? Date
            
            if let contractEnd = contractEndDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                contractEndTextField.text = dateFormatter.string(from: contractEnd)
            }
            
            firstNameTextField.text = firstName
			lastNameTextField.text = firstName == lastName ? "" : lastName
            positionDescTextField.text = positionDesc
            phoneTextField.text = pfObject[ObjectKeys.Person.phone] as? String
            emailTextField.text = pfObject[ObjectKeys.Person.email] as? String
			photoImageView.pffile = pfObject[ObjectKeys.Person.photo] as? PFFile
            
            personInfoParentViewController?.navigationItem.title = firstName != lastName ? "\(firstName) \(lastName)" : "\(firstName)"
            setEditing(false, animated: true)
        }
		else {
			setEditing(true, animated: true)
		}
	}

	func initViews() {
		callButton.layer.cornerRadius = 5
		phoneTextField.delegate = PhoneTextFieldDelegate.shared
	}
    
	func heightForView() -> CGFloat {
		//return 150; // TODO heightForView
        return 210 //return 178
	}

	// MARK: - UI Actions

	@IBAction func didTapEmailButton(_ sender: UIButton) {
		if let email = emailTextField.text {
			UIApplication.shared.mailTo(email: email)
		}
	}

	@IBAction func didTapCallButton(_ sender: UIButton) {
		if let phone = self.phoneTextField.text {
			UIApplication.shared.call(phoneNumber: phone)
		}
	}

	func onRightBarButtonTap(_ sender: UIBarButtonItem) {

		if isEditing {

			if isValid() {

				if personPFObject != nil {

					let personCurrentEmail:String = personPFObject![ObjectKeys.Person.email] as! String
					let personNewEmail:String = emailTextField.text!

					if  personCurrentEmail != personNewEmail {
						validateIfPersonExists(completion: { (success: Bool, error: Error?) in
							if (success) {
								self.editPerson()
								self.setEditing(false, animated: true)
							}
						})
					}
					else {
						editPerson()
						self.setEditing(false, animated: true)
					}
				}
				else {
					validateIfPersonExists(completion: { (success: Bool, error: Error?) in
						if (success) {
							self.createPerson()
							self.setEditing(false, animated: true)
						}
					})
				}
			}
		}
		else {
			setEditing(true, animated: true)
		}
	}

	// MARK: - Helpers

	func isValid() -> Bool {

		if (firstNameTextField.text?.isEmpty)! {
			ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "First Name cannot be empty")
			return false
		}

		if (emailTextField.text?.isEmpty)! {
			ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Email cannot be empty")
			return false
		}

		if !emailTextField.text!.isValidEmail() {
			ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Please enter a valid email")
			return false
		}

		return true
	}

	func validateIfPersonExists(completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {

		ParseClient.sharedInstance().fetchPersonFor(email: emailTextField.text!) {
			(person: PFObject?, error: Error?) in

			if error != nil {
				completion(true, error)
			}
			else {
				self.ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "User already exists. Please enter a new email")
			}
		}
	}

	func configureButton(textField: UITextField, button: UIButton) {
		let text = textField.text ?? ""
		let buttonTitle = NSMutableAttributedString(
			string:text,
			attributes: [NSForegroundColorAttributeName : UIColor.pulseAccentColor(),
			             NSUnderlineStyleAttributeName : 1] as [String : Any])
		textField.isHidden = !isEditing
		button.isHidden = isEditing || text == ""
		button.setAttributedTitle(buttonTitle, for: .normal)
	}

	override func viewDidLayoutSubviews() {
		setupViews()
	}

	func setupViews() {
        lastNameTextField.isHidden = isEditing ? false : (lastNameTextField.text == "" ? true : false)
        positionDescTextField.isHidden = isEditing ? false : (positionDescTextField.text == "" ? true : false)
        contractEndTextField.isHidden = isEditing ? false : (contractEndTextField.text == "" ? true : false)
        
		if isEditing {
			UIExtensions.setupDarkViewFor(textField: firstNameTextField)
			UIExtensions.setupDarkViewFor(textField: lastNameTextField)
			UIExtensions.setupDarkViewFor(textField: emailTextField)
			UIExtensions.setupDarkViewFor(textField: phoneTextField)
            UIExtensions.setupDarkViewFor(textField: positionDescTextField)
            UIExtensions.setupDarkViewFor(textField: contractEndTextField)
		}
		else {
            contractEndTextField.layer.sublayers?.removeAll()
            emailTextField.layer.sublayers?.removeAll()
            firstNameTextField.layer.sublayers?.removeAll()
            lastNameTextField.layer.sublayers?.removeAll()
            phoneTextField.layer.sublayers?.removeAll()
            positionDescTextField.layer.sublayers?.removeAll()
		}
	}

    fileprivate func dateFromString(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    fileprivate func stringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
	// MARK: - Edit/Save

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		personInfoParentViewController?.setEditing(editing, animated: animated)

		phoneTextField.isUserInteractionEnabled = isEditing
		emailTextField.isUserInteractionEnabled = isEditing
		lastNameTextField.isUserInteractionEnabled = isEditing
		firstNameTextField.isUserInteractionEnabled = isEditing
        positionDescTextField.isUserInteractionEnabled = isEditing
        contractEndTextField.isUserInteractionEnabled = isEditing
		photoImageView.isUserInteractionEnabled = isEditing

        if let contractEndText = contractEndTextField.text,
            !contractEndText.isEmpty,
            !isEditing {
            contractEndTextField.text = "Contract Ends: \(contractEndText)"
            
            if let contractEnd = dateFromString(dateString: contractEndText),
                contractEnd >= Date() {
                contractEndTextField.textColor = UIColor.darkGray
            } else {
                contractEndTextField.textColor = UIColor.pulseOverdueColor()
            }
            
        } else if isEditing {
            contractEndTextField.text = contractEndTextField.text?.replacingOccurrences(of: "Contract Ends: ", with: "")
        }
        
		configureButton(textField: phoneTextField, button: callButton)
		configureButton(textField: emailTextField, button: emailButton)

		setupViews()
	}

	func editPerson() {

		NSLog("Editing current person")

		if let pfPerson = personPFObject {
			SVProgressHUD.show()
			let firstName = firstNameTextField.text!
			pfPerson[ObjectKeys.Person.firstName] = firstName

			let lastName = (lastNameTextField.text?.isEmpty)! ? firstName : lastNameTextField.text
			pfPerson[ObjectKeys.Person.lastName] = lastName
            lastNameTextField.text = firstName != lastName ? lastName : ""
            
			pfPerson[ObjectKeys.Person.email] = emailTextField.text
			pfPerson[ObjectKeys.Person.phone] = phoneTextField.text
            pfPerson[ObjectKeys.Person.positionDesc] = positionDescTextField.text
            
            if let contractEndDate = contractEndTextField.text,
                !contractEndDate.isEmpty {
                let date = dateFromString(dateString: contractEndDate)
                pfPerson[ObjectKeys.Person.contractEndDate] = date
            }
            
			if let photoData = photoData {
				SVProgressHUD.show()

				Person.savePhotoInPerson(parsePerson: pfPerson, photo: photoData, withCompletion: {
					(success: Bool, error: Error?) in
					self.updatePersonFinished(success: success, error: error)
				})
			}
			else {
				pfPerson.saveInBackground(block: {
					(success: Bool, error: Error?) in
					self.updatePersonFinished(success: success, error: error)
				})
			}
		}
	}

	func updatePersonFinished(success: Bool, error: Error?) {

		SVProgressHUD.dismiss()

		if success {
			ABIShowDropDownAlert(type: AlertTypes.success, title: "Success!", message: "Successfully updated team member")
		}
		else {
            if let error = error {
                ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error", message: "Unable to update team member, error: \(error.localizedDescription)")
            } else {
                ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error", message: "Unable to update team member")
            }
		}
	}

	func createPerson() {

		NSLog("Creating new person")

		validateIfPersonExists(completion: { (success: Bool, error: Error?) in
			if (success) {
				self.editPerson()
			}
		})

		SVProgressHUD.show()
		let firstName = firstNameTextField.text!
		let lastName = (lastNameTextField.text?.isEmpty)! ? firstName : lastNameTextField.text
        lastNameTextField.text = firstName != lastName ? lastName : ""

		person = Person(firstName: firstName,
		                lastName: lastName!)
		person?.email = emailTextField.text
		person?.phone = phoneTextField.text
        person?.positionDesc = positionDescTextField.text
        
        if let contractEndDate = contractEndTextField.text {
            let date = dateFromString(dateString: contractEndDate)
            person?.contractEndDate = date
        }
        
		person?.photo = photoData

		ParseClient.sharedInstance().getCurrentPerson(completion: { (manager: PFObject?, error: Error?) in
			if let error = error {
				debugPrint("Error finding the person matching current user, error: \(error.localizedDescription)")
			} else {
				self.person?.managerId = manager?.objectId
				self.person?.companyId = manager?[ObjectKeys.Person.companyId] as? String
				let positionId = (manager?[ObjectKeys.Person.positionId] as? String)!
				self.person?.positionId = String(Int(positionId)! - 1)

				Person.savePersonToParse(person: self.person!) {
					(success: Bool, error: Error?) in
					if success {
						self.ABIShowDropDownAlertWithDelegate(
							type: AlertTypes.success,
							title: "Success!",
							message: "Successfully added team member",
                            delegate: self)
						SVProgressHUD.dismiss()
						NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.Team.addTeamMemberSuccessful), object: self, userInfo: nil)
					}
					SVProgressHUD.dismiss()
				}
			}
		})
	}
}

// MARK: - PhotoImageViewDelegate

extension PersonDetailsViewController : PhotoImageViewDelegate {

	func didSelectImage(sender: PhotoImageView) {
		self.photoData = sender.photoData
	}
}

// MARK: - RKDropDownAlertDelegate

extension PersonDetailsViewController: RKDropdownAlertDelegate {
    
    func dropdownAlertWasDismissed() -> Bool {
        // Temporary fix to pop page after new person was created to "hide" bugs
        // Really though, if new person is created, page shouldn't be popped so the user can still use that page to add To Do items, meetings, etc.
        let _ = self.navigationController?.popViewController(animated: true)
        return true
    }
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
}

extension PersonDetailsViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == contractEndTextField {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = UIDatePickerMode.date
            datePicker.backgroundColor = UIColor.pulseLightPrimaryColor()
            
            if let dateString = contractEndTextField.text, let date = dateFromString(dateString: dateString) {
                datePicker.setDate(date, animated: true)
            } else {
                let date = Date()
                datePicker.setDate(date, animated: false)
            }
            
            contractEndTextField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(onContractEndDatePickerValueChanged(_:)), for: .valueChanged)
        }
    }
    
    @objc func onContractEndDatePickerValueChanged(_ sender: UIDatePicker) {
        contractEndTextField.text = stringFromDate(date: sender.date)
    }
    
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		textField.resignFirstResponder()

		if textField == firstNameTextField {
			lastNameTextField.becomeFirstResponder()
		}
		else if textField == lastNameTextField {
			positionDescTextField.becomeFirstResponder()
		}
        else if textField == positionDescTextField {
            emailTextField.becomeFirstResponder()
        }
		else if textField == emailTextField {
			phoneTextField.becomeFirstResponder()
        }
        /*
        else if textField == phoneTextField {
            contractEndTextField.becomeFirstResponder()
        }*/
		return true
	}
}
