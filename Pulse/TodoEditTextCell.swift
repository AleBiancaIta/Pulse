//
//  TodoEditTextCell.swift
//  Pulse
//
//  Created by Itasari on 11/22/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TodoEditTextCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var todoLabel: UILabel!
    
    var todoItem: PFObject! {
        didSet {
            if let text = todoItem[ObjectKeys.ToDo.text] as? String {
                todoLabel.text = text
            }
            // TODO: SHOW OR HIDE TextField or Label
            todoTextField.isHidden = true
        }
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
