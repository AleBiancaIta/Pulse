//
//  TeamCollectionCell.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class TeamCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    
	@IBOutlet weak var profileImageView: PhotoImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surveyValue1Label: UILabel!
    @IBOutlet weak var surveyValue2Label: UILabel!
    @IBOutlet weak var surveyValue3Label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        debugPrint("team cell loaded")

//        surveyValue1Label.text = "0"
//        surveyValue2Label.text = "1"
//        surveyValue3Label.text = "3"
//        nameLabel.text = "Testing"
    }
}
