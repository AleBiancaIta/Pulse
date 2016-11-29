//
//  LoginSignUpViewController.swift
//  Pulse
//
//  Created by Itasari on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class LoginSignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIExtensions.gradientBackgroundFor(view: view)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Actions

//    @IBAction func onSignUpButtonTap(_ sender: UIButton) {
//        let signUpVC = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
//        self.present(signUpVC, animated: true, completion: nil)
//    }
//    
//    @IBAction func onLoginButtonTap(_ sender: UIButton) {
//        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
//        self.present(loginVC, animated: true, completion: nil)
//    }
    
    
    /*
    @IBAction func onSkipButtonTap(_ sender: UIButton) {
        // if first time login, get the device ID
        // subsequent login, pull the data from Parse using device ID
        debugPrint("Skip button tapped")
        
        // Anonymous user implementation - might be redundant with enable automatic user?
        // Clear out current user just in case
        if PFUser.current() != nil {
            PFUser.logOut()
        }

        PFAnonymousUtils.logIn { (user: PFUser?, error: Error?) in
            if let error = error {
                self.ABIShowAlert(title: "Error", message: "Failed to log in anonymously: \(error.localizedDescription)", sender: nil, handler: nil)
            } else {
                debugPrint("Anonymous user logged in")
                debugPrint("Anonymous user is \(PFUser.current()), username is \(PFUser.current()?.username), id is \(PFUser.current()?.objectId)")
        
                // segue to dashboard view
                let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
                let dashboardVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.dashboardNavVC)
                self.present(dashboardVC, animated: true, completion: nil)
            }
        }
        
//        PFUser.enableAutomaticUser()
//        PFUser.current()?.saveInBackground(block: { (succes: Bool, error: Error?) in
//            let user = PFUser.current()
//            debugPrint("user is \(user), username is \(user?.username), id is \(user?.objectId)")
//        })
//        debugPrint("user is \(PFUser.current()), username is \(PFUser.current()?.username), id is \(PFUser.current()?.objectId)")
//        

    }*/
}
