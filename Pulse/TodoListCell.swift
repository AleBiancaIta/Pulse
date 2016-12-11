//
//  TodoListCell.swift
//  Pulse
//
//  Created by Itasari on 11/19/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

@objc protocol TodoListCellDelegate {
    @objc optional func todoListCell(_ todoListCell: TodoListCell, isCompleted: Bool)
}

class TodoListCell: UITableViewCell {
    
    
    @IBOutlet weak var todoBackgroundView: UIView!
    @IBOutlet weak var squareImageView: UIImageView!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var meetingLabel: UILabel!
    
    let parseClient = ParseClient.sharedInstance()
    var isCompleted: Bool!
    weak var delegate: TodoListCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.pulseLightPrimaryColor()
        selectedBackgroundView = bgColorView
    }
    
    var hasMeeting: Bool! {
        didSet {
            if hasMeeting! {
                meetingLabel.isHidden = false
            } else {
                meetingLabel.isHidden = true
            }
        }
    }
    
    var hasPerson: Bool! {
        didSet {
            if hasPerson! {
                nameLabel.isHidden = false
            } else {
                nameLabel.isHidden = true
            }
        }
    }
    
    var todoObject: PFObject! {
        didSet {
            todoLabel.text = todoObject[ObjectKeys.ToDo.text] as? String
            
            if let _ = todoObject[ObjectKeys.ToDo.completedAt] {
                isCompleted = true
                squareImageView.image = UIImage(named: "CircleChecked")
            } else {
                isCompleted = false
                squareImageView.image = UIImage(named: "Circle")
            }
            
            if let personId = todoObject[ObjectKeys.ToDo.personId] as? String {
                
                // Probably not the best place to do this?? TODO
                parseClient.fetchPersonFor(personId: personId) { (person: PFObject?, error: Error?) in
                    if let error = error {
                        debugPrint("error: \(error.localizedDescription)")
                    } else {
                        if let person = person {
                            let firstName = person[ObjectKeys.Person.firstName] as! String
                            let lastName = person[ObjectKeys.Person.lastName] as! String
                            
                            self.nameLabel.text = firstName != lastName ? "\(firstName) \(lastName)" : firstName
                        }
                    }
                }
            }
            
            if let meetingId = todoObject[ObjectKeys.ToDo.meetingId] as? String {
                
                parseClient.fetchMeetingFor(meetingId: meetingId) { (meeting: PFObject?, error: Error?) in
                    if let error = error {
                        debugPrint("error: \(error.localizedDescription)")
                    } else {
                        if let meeting = meeting {
                            let meetingDate = meeting[ObjectKeys.Meeting.meetingDate] as! Date
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            dateFormatter.timeStyle = .none
                            self.meetingLabel.text = dateFormatter.string(from: meetingDate)
                        }
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTodoBackgroundView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @IBAction func onCompletedButtonTap(_ sender: UIButton) {
        squareImageViewTap()
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
    
    fileprivate func squareImageViewTap() {
        delegate?.todoListCell?(self, isCompleted: isCompleted)
    }
}
