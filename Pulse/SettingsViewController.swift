//
//  SettingsViewController.swift
//  Pulse
//
//  Created by Itasari on 11/12/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {
    
    fileprivate let settingsHeaderCell = "SettingsHeaderCell"
    fileprivate let settingsContentCell = "SettingsContentCell"
    
    fileprivate let settingsContent = ["Change Password", "Sign Up", "Log Out"]
    
    @IBOutlet var settingsTableView: UITableView!
    var user: PFUser! = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
