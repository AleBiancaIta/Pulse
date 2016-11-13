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
    
    fileprivate let changePasswordSegue = "changePasswordSegue"
    fileprivate let updateProfileSegue = "updateProfileSegue"
    
    // Note: Sign Up is for anonymous user who wants to sign up for the account
    fileprivate let settingsContent = ["User Info", "Change Password", "Sign Up", "Log Out"]
    
    @IBOutlet var settingsTableView: UITableView!
    var user: PFUser! = PFUser.current()
    var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.estimatedRowHeight = 50
        settingsTableView.rowHeight = UITableViewAutomaticDimension
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

// MARK: - SettingsViewController: UITableViewDelegate, UITableViewDataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return settingsContent.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: settingsHeaderCell, for: indexPath) as! SettingsHeaderCell
            cell.user = user // NEED TO CHANGE THIS TO PERSON
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: settingsContentCell, for: indexPath)
            cell.textLabel?.text = settingsContent[indexPath.row]
            
            if indexPath.row == 0 || indexPath.row == 1 {
                // only enable if it's NOT anonymous user
                if !(PFAnonymousUtils.isLinked(with: user)) {
                    cell.isUserInteractionEnabled = true
                    cell.textLabel?.textColor = UIColor.black
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.textColor = UIColor.lightGray
                }
            } else if indexPath.row == 2 { // Sign Up
                // only enable if it's anonymous user
                if PFAnonymousUtils.isLinked(with: user) {
                    cell.isUserInteractionEnabled = true
                    cell.textLabel?.textColor = UIColor.black
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.textColor = UIColor.lightGray
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            // do nothing
        } else if indexPath.section == 1 {
            if indexPath.row == 0 { // User Info
                debugPrint("did select row User Info")
                performSegue(withIdentifier: updateProfileSegue, sender: nil)
            } else if indexPath.row == 1 { // Change Password
                debugPrint("did select row Change Password")
                performSegue(withIdentifier: changePasswordSegue, sender: nil)
            } else if indexPath.row == 2 { // Sign Up
                debugPrint("did select row Sign Up")
                self.segueToStoryboard(id: StoryboardID.signupVC)
            } else if indexPath.row == 3 { // Log Out
                logOut()
            }
        }
    }
    
    // MARK: - Helpers

    fileprivate func logOut() {
        
        // If anonymous user, give them a heads up that their data will be deleted if they don't sign up
        if PFAnonymousUtils.isLinked(with: user) {
            debugPrint("user is anonymous, give them a warning")
            showAlertWithActions(title: "Alert", message: "You're currently logged in as anonymous user. To save your data, sign up for an account", actionTitle1: "Sign Up", actionTitle2: "Log Out", sender: nil, handler1: { (alertAction1: UIAlertAction) in
                if alertAction1.title == "Sign Up" {
                    debugPrint("Sign Up is being clicked")
                    self.segueToStoryboard(id: StoryboardID.signupVC)
                }
            }, handler2: { (alertAction2: UIAlertAction) in
                if alertAction2.title == "Log Out" {
                    debugPrint("Log Out is being clicked")
                    PFUser.logOutInBackground(block: { (error: Error?) in
                        if let error = error {
                            debugPrint("Log out failed with error: \(error.localizedDescription)")
                        } else {
                            debugPrint("User log out successfully")
                            self.segueToStoryboard(id: StoryboardID.loginSignupVC)
                        }
                    })
                }
            })
        } else {
            // If not anonymous, log out user and take them back to the sign up page
            PFUser.logOutInBackground(block: { (error: Error?) in
                if let error = error {
                    debugPrint("Log out failed with error: \(error.localizedDescription)")
                } else {
                    debugPrint("User log out successfully")
                    self.segueToStoryboard(id: StoryboardID.loginSignupVC)
                }
            })
        }
    }

    fileprivate func segueToStoryboard(id: String) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginSignUpVC = storyboard.instantiateViewController(withIdentifier: id)
        self.present(loginSignUpVC, animated: true, completion: nil)
    }
}
