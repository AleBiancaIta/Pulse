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
    
    @IBOutlet weak var profileImageView: PhotoImageView!
    @IBOutlet weak var usernameLabel: UILabel!

	weak var parent: UIViewController? {
		didSet {
			profileImageView.viewController = parent
		}
	}

    var person: PFObject! {
        didSet {
            let firstName = person[ObjectKeys.Person.firstName] as? String ?? ""
            let lastName = person[ObjectKeys.Person.lastName] as? String ?? ""
            let name = firstName != lastName ? "\(firstName) \(lastName)" : firstName
            usernameLabel.text = "Hello,\n\(name)"
			profileImageView.pffile = person[ObjectKeys.Person.photo] as? PFFile
        }
    }
    
    var user: PFUser! {
        didSet {
            // Check if user is anonymous
//            if PFAnonymousUtils.isLinked(with: user) {
//                usernameLabel.text = "Hello, Anonymous"
//                emailLabel.isHidden = true
//            } else {
            //}
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

		profileImageView.delegate = self
		profileImageView.isEditable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension SettingsHeaderCell : PhotoImageViewDelegate {

	func didSelectImage(sender: PhotoImageView) {
		Person.savePhotoInPerson(parsePerson: person, photo: sender.photoData!, withCompletion: nil)
	}
}
