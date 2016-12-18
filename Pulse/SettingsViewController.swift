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
    //fileprivate let settingsContent = ["User Info", "Change Password", "Sign Up", "Log Out"]
    fileprivate let settingsContent = ["User Information", "Change Password", "Send Feedback"]
    fileprivate let settingsSubcontent = ["Update your Pulse user information or password with a few taps", "Change the password associated with your Pulse account", "Send us an email to provide feedback, ask questions, or report bugs"]
    fileprivate let settingsImageName = ["Passport2", "Keylock2", "Help"]
    
    fileprivate let parseClient = ParseClient.sharedInstance()
    
    @IBOutlet weak var settingsTableView: UITableView!
    var user: PFUser! = PFUser.current()
    var person: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        UIExtensions.gradientBackgroundFor(view: view)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        settingsTableView.estimatedRowHeight = 100
        settingsTableView.rowHeight = UITableViewAutomaticDimension
        getCurrentPerson()
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton(_:)))
        
        settingsTableView.register(UINib(nibName: "CustomTextCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
    }
    
    @IBAction func onDoneButtonTap(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    /*
    @objc fileprivate func onDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }*/
    
    // MARK: - Helpers
    
    fileprivate func getCurrentPerson() {
        parseClient.getCurrentPerson { (person: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("Unable to fetch current person with error: \(error.localizedDescription)")
            } else {
                if let person = person {
                    self.person = person
                    self.settingsTableView.reloadData()
                } else {
                    debugPrint("getCurrentPerson is returning nil")
                }
            }
        }
        
    }
    
    // MARK: - deinit
    
    deinit {
        debugPrint("SettingsViewController deinitialized")
    }
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
            cell.user = user
            if let person = self.person {
                cell.person = person
            }
			cell.parent = self
			cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! CustomTextCell
            cell.message = settingsContent[indexPath.row]
            cell.submessage = settingsSubcontent[indexPath.row]
            cell.imageName = settingsImageName[indexPath.row]
            
            /*
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
            }*/
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
            } else if indexPath.row == 2 { // Help
				UIApplication.shared.mailTo(email: "mailto:2b8wad2qg5@snkmail.com?subject=Pulse%20Feedback")
            } //else if indexPath.row == 3 { // Log Out
              //  logOut()
            //}
        }
    }
}
