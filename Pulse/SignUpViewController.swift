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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var photoData: Data?
    var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initImage()
    }
    
    // MARK: - Initializations
    
    func initImage() {
        imagePicker.delegate = self
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "DefaultPhoto")
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
                    self.showAlert(title: "Error", message: "New user sign up error: \(error.localizedDescription)", sender: nil, handler: nil)
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
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let dashboardNavVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.dashboardNavVC)
        self.present(dashboardNavVC, animated: true, completion: nil)
    }
    
    fileprivate func validateEntry() -> Bool {
        // Check if email is empty
        guard !((emailTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Email field cannot be empty", sender: nil, handler: nil)
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
        
        // Check if company name field is empty
        guard !((companyNameTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Company name field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        // Check if position field is empty
        guard !((positionTextField.text?.isEmpty)!) else {
            showAlert(title: "Error", message: "Position field cannot be empty", sender: nil, handler: nil)
            return false
        }
        
        return true
    }
    
    // MARK: - Image
    
    @IBAction func didTapProfileImageView(_ sender: UITapGestureRecognizer) {
        showAlertAction()
    }
    
    func showAlertAction() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from library", style: .default) {
            (UIAlertAction) in
            self.chooseFromLibrary()
        }
        
        let takeProfilePhotoAction = UIAlertAction(title: "Take profile photo", style: .default) {
            (UIAlertAction) in
            self.takeProfilePhoto()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(chooseFromLibraryAction)
        alertController.addAction(takeProfilePhotoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func takeProfilePhoto() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    func chooseFromLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //let chosenImageData = NSData(data: UIImagePNGRepresentation(chosenImage)!)
        //let imageSize = chosenImageData.length
        
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.image = chosenImage
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
        let scaledImage = scaleImageWith(newImage: chosenImage, newSize: CGSize(width: 120, height: 120))
        photoData = UIImagePNGRepresentation(scaledImage)
        
        //let photoData2 = NSData(data: photoData!)
        //let photoSize = photoData2.length
        
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func scaleImageWith(newImage:UIImage, newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        UIGraphicsEndImageContext()
        return newImage
    }
}
