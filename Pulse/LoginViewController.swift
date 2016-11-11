//
//  LoginViewController.swift
//  Pulse
//
//  Created by Itasari on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLoginButtonTap(_ sender: UIButton) {
        // Login to Parse        
    }
    
    @IBAction func onForgetPasswordButtonTap(_ sender: UIButton) {
        let forgetVC = ForgetPasswordViewController(nibName: "ForgetPasswordViewController", bundle: nil)
        self.present(forgetVC, animated: true, completion: nil)
    }
    
    @IBAction func onCancelButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
