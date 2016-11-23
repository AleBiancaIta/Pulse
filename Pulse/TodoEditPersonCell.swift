//
//  TodoEditPersonCell.swift
//  Pulse
//
//  Created by Itasari on 11/22/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TodoEditPersonCell: UITableViewCell {
    
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var forLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    var selectedPerson: PFObject! {
        didSet {
            configureNameLabel(person: selectedPerson)
        }
    }
    
    var firstRow: Bool? {
        didSet{
            if firstRow! {
                // Show down arrow
                downArrowImageView.isHidden = false
                downArrowImageView.image = UIImage(named: "DownArrow")
                forLabel.isHidden = false
            } else {
                // Hide down arrow
                downArrowImageView.isHidden = true
                forLabel.isHidden = true
            }
        }
    }
    
    var person: PFObject! {
        didSet {
            configureNameLabel(person: person)
        }
    }
    
    fileprivate func configureNameLabel(person: PFObject) {
        let firstName = person[ObjectKeys.Person.firstName] as? String ?? ""
        let lastName = person[ObjectKeys.Person.lastName] as? String ?? ""
        nameLabel.text = "\(firstName) \(lastName)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCellBackgroundView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Helpers
    fileprivate func configureCellBackgroundView() {
        cellBackgroundView.layer.cornerRadius = 5.0
        cellBackgroundView.layer.borderWidth = 1.0
        cellBackgroundView.layer.borderColor = UIColor.darkGray.cgColor
        cellBackgroundView.layer.shadowRadius = 5.0
        cellBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cellBackgroundView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
    
}
