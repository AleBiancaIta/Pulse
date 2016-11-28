//
//  MessageCell.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var message: String! {
        didSet {
            messageLabel.text = message
        }
    }
}
