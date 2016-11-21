//
//  TodoListCell.swift
//  Pulse
//
//  Created by Itasari on 11/19/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TodoListCell: UITableViewCell {
    
    
    @IBOutlet weak var todoBackgroundView: UIView!
    @IBOutlet weak var squareImageView: UIImageView!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var todoObject: PFObject! {
        didSet {
            todoLabel.text = todoObject[ObjectKeys.ToDo.text] as? String
            nameLabel.text = todoObject[ObjectKeys.ToDo.personId] as? String
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTodoBackgroundView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(squareImageViewTap(_:)))
        squareImageView.addGestureRecognizer(tapGesture)
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
    
    @objc fileprivate func squareImageViewTap(_ sender: UITapGestureRecognizer) {
        debugPrint("square image view tap")
    }
}
