//
//  TodoAddCell.swift
//  Pulse
//
//  Created by Itasari on 11/19/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class TodoAddCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        todoTextField.placeholder = "Add a follow-up item..."
        configureCellBackgroundView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Helpers
    fileprivate func configureCellBackgroundView() {
        cellBackgroundView.layer.cornerRadius = 5.0
        cellBackgroundView.layer.borderWidth = 1.0
        cellBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
        cellBackgroundView.layer.shadowRadius = 5.0
        cellBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cellBackgroundView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }

    
}
