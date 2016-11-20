//
//  TodoListCell.swift
//  Pulse
//
//  Created by Itasari on 11/19/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class TodoListCell: UITableViewCell {
    
    
    @IBOutlet weak var todoBackgroundView: UIView!
    @IBOutlet weak var squareImageView: UIImageView!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTodoBackgroundView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Helpers
    fileprivate func configureTodoBackgroundView() {
        todoBackgroundView.layer.cornerRadius = 5.0
        todoBackgroundView.layer.borderWidth = 1.0
        todoBackgroundView.layer.borderColor = UIColor.darkGray.cgColor
        todoBackgroundView.layer.shadowRadius = 5.0
        todoBackgroundView.layer.shadowColor = UIColor.black.cgColor
        todoBackgroundView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
}
