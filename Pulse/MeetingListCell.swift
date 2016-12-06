//
//  MeetingListCell.swift
//  Pulse
//
//  Created by Itasari on 12/5/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class MeetingListCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var submessageLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.pulseLightPrimaryColor()
        selectedBackgroundView = bgColorView
    }
    
    var message: String! {
        didSet {
            messageLabel.text = message
        }
    }
    
    var submessage: String? {
        didSet {
            if let submessage = submessage {
                submessageLabel.text = submessage
            }
        }
    }
    
    var imageName: String? {
        didSet {
            if let imageName = imageName {
                cellImageView.image = UIImage(named: imageName)
                cellImageView.tintColor = UIColor.pulseAccentColor()
            }
        }
    }
    
}
