//
//  LoginSignUpViewController.swift
//  Pulse
//
//  Created by Itasari on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class LoginSignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func onSkipButtonTap(_ sender: UIButton) {
        // if first time login, get the device ID
        // subsequent login, pull the data from Parse using device ID
        debugPrint("Skip button tapped")
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
