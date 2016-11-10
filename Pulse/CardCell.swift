//
//  CardCell.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onUpButton(_ sender: AnyObject) {
        print("up")
    }

    @IBAction func onDownButton(_ sender: AnyObject) {
        print("down")
    }
    
    @IBAction func onDeleteButton(_ sender: AnyObject) {
        print("delete")
    }
}
