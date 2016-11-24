//
//  SettingsHeaderCell.swift
//  Pulse
//
//  Created by Itasari on 11/12/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class SettingsHeaderCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var person: PFObject! {
        didSet {
            let firstName = person[ObjectKeys.Person.firstName] as? String ?? ""
            let lastName = person[ObjectKeys.Person.lastName] as? String ?? ""
            usernameLabel.text = "Hello, \(firstName) \(lastName)"
        }
    }
    
    var user: PFUser! {
        didSet {
            // Check if user is anonymous
//            if PFAnonymousUtils.isLinked(with: user) {
//                usernameLabel.text = "Hello, Anonymous"
//                emailLabel.isHidden = true
//            } else {
                if let user = user {
                    emailLabel.text = user.email
                }
            //}
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
