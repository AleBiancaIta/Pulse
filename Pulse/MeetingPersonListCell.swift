//
//  MeetingPersonListCell.swift
//  Pulse
//
//  Created by Itasari on 11/26/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class MeetingPersonListCell: UITableViewCell {

    @IBOutlet weak var personListBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    var firstRow: Bool? {
        didSet{
            if firstRow! {
                // Show down arrow
                downArrowImageView.isHidden = false
                downArrowImageView.image = UIImage(named: "DownArrow")
            } else {
                // Hide down arrow
                downArrowImageView.isHidden = true
            }
        }
    }
    
    var highlightBackground: Bool! {
        didSet {
            personListBackgroundView.backgroundColor = highlightBackground! ? UIColor.lightGray : UIColor.white
        }
    }
    
    var selectedPerson: PFObject! {
        didSet {
            configureNameLabel(person: selectedPerson)
        }
    }
    
    var person: PFObject! {
        didSet {
            configureNameLabel(person: person)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCellBackgroundView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    fileprivate func configureNameLabel(person: PFObject) {
        let firstName = person[ObjectKeys.Person.firstName] as? String ?? ""
        let lastName = person[ObjectKeys.Person.lastName] as? String ?? ""
        nameLabel.text = "\(firstName) \(lastName)"
    }
    
    fileprivate func configureCellBackgroundView() {
        //personListBackgroundView.backgroundColor = UIColor.white
        personListBackgroundView.layer.cornerRadius = 5.0
        personListBackgroundView.layer.borderWidth = 1.0
        personListBackgroundView.layer.borderColor = UIColor.darkGray.cgColor
        personListBackgroundView.layer.shadowRadius = 5.0
        personListBackgroundView.layer.shadowColor = UIColor.black.cgColor
        personListBackgroundView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
    
}
