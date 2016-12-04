//
//  TeamCollectionCell.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

@objc protocol TeamCollectionCellDelegate {
    @objc optional func teamCollectionCell(_ teamCollectionCell: TeamCollectionCell, survey: PFObject)
}

class TeamCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    
	@IBOutlet weak var profileImageView: PhotoImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surveyValue1Button: UIButton!
    @IBOutlet weak var surveyValue2Button: UIButton!
    @IBOutlet weak var surveyValue3Button: UIButton!
    
    weak var delegate: TeamCollectionCellDelegate?
    
    var survey: PFObject! {
        didSet {
            let surveyValue1 = survey[ObjectKeys.Survey.surveyValueId1] as? Int ?? 99
            let surveyValue2 = survey[ObjectKeys.Survey.surveyValueId2] as? Int ?? 99
            let surveyValue3 = survey[ObjectKeys.Survey.surveyValueId3] as? Int ?? 99
            
            setUpSurvey1(value: surveyValue1)
            setUpSurvey2(value: surveyValue2)
            setUpSurvey3(value: surveyValue3)
        }
    }
    
    // happiness
    fileprivate func setUpSurvey1(value: Int) {
        switch value {
        case 0:
            surveyValue1Button.setImage(UIImage(named: "Grumpy"), for: .normal)
            surveyValue1Button.tintColor = UIColor.pulseBadSurveyColor()
            surveyValue1Button.backgroundColor = UIColor.clear
        case 1:
            surveyValue1Button.setImage(UIImage(named: "Speechless"), for: .normal)
            surveyValue1Button.tintColor = UIColor.pulseNeutralSurveyColor()
            surveyValue1Button.backgroundColor = UIColor.clear
        case 2:
            surveyValue1Button.setImage(UIImage(named: "Smiley"), for: .normal)
            surveyValue1Button.tintColor = UIColor.pulseGoodSurveyColor()
            surveyValue1Button.backgroundColor = UIColor.clear
        default:
            surveyValue1Button.setImage(UIImage(named: "Smiley"), for: .normal)
            surveyValue1Button.tintColor = UIColor.pulseNoDataSurveyColor()
        }
    }
    
    // engagement
    fileprivate func setUpSurvey2(value: Int) {
        switch value {
        case 0:
            surveyValue2Button.setImage(UIImage(named: "ThumbsDown"), for: .normal)
            surveyValue2Button.tintColor = UIColor.pulseBadSurveyColor() //UIColor.red
            surveyValue2Button.backgroundColor = UIColor.clear
        case 1:
            surveyValue2Button.setImage(UIImage(named: "ThumbsMiddle"), for: .normal)
            surveyValue2Button.tintColor = UIColor.pulseNeutralSurveyColor() //UIColor.yellow
            surveyValue2Button.backgroundColor = UIColor.clear
        case 2:
            surveyValue2Button.setImage(UIImage(named: "ThumbsUp"), for: .normal)
            surveyValue2Button.tintColor = UIColor.pulseGoodSurveyColor() //UIColor.green
            surveyValue2Button.backgroundColor = UIColor.clear
        default:
            surveyValue2Button.setImage(UIImage(named: "ThumbsMiddle"), for: .normal)
            surveyValue2Button.tintColor = UIColor.pulseNoDataSurveyColor() //UIColor.darkGray
        }
    }
    
    // workload
    fileprivate func setUpSurvey3(value: Int) {
        switch value {
        case 0:
            surveyValue3Button.setImage(UIImage(named: "Cross4"), for: .normal)
            surveyValue3Button.tintColor = UIColor.pulseBadSurveyColor() //UIColor.red
            surveyValue3Button.backgroundColor = UIColor.clear
        case 1:
            surveyValue3Button.setImage(UIImage(named: "Circle3"), for: .normal)
            surveyValue3Button.tintColor = UIColor.pulseNeutralSurveyColor() //UIColor.yellow
            surveyValue3Button.backgroundColor = UIColor.clear
        case 2:
            surveyValue3Button.setImage(UIImage(named: "Checkmark5"), for: .normal)
            surveyValue3Button.tintColor = UIColor.pulseGoodSurveyColor() //UIColor.green
            surveyValue3Button.backgroundColor = UIColor.clear
        default:
            surveyValue3Button.setImage(UIImage(named: "Circle3"), for: .normal)
            surveyValue3Button.tintColor = UIColor.pulseNoDataSurveyColor() //UIColor.darkGray
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        surveyValue1Button.tintColor = UIColor.clear
        surveyValue2Button.tintColor = UIColor.clear
        surveyValue3Button.tintColor = UIColor.clear
        profileImageView.pffile = nil
    }
    
    // MARK: - Actions
    
    @IBAction func onSurveyButtonTap(_ sender: UIButton) {
        delegate?.teamCollectionCell?(self, survey: self.survey)
    }
}
