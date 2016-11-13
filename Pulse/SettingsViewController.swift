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
    
    // Note: Sign Up is for anonymous user who wants to sign up for the account
    fileprivate let settingsContent = ["User Info", "Change Password", "Sign Up", "Log Out"]
    
    @IBOutlet var settingsTableView: UITableView!
    var user: PFUser! = PFUser.current()
    var person: PFObject!
    
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
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            // do nothing
        } else {
            debugPrint("did select row")
        }
    }
    
}
