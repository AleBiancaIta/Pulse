//
//  MeetingDetailsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit

class MeetingDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var personTextField: UITextField! // Person ID // TODO should be name
    
    @IBOutlet weak var notesTextView: UITextView!
    
    // TODO use objectkey.survey to display on labels
    @IBOutlet weak var survey1Low: UISwitch! // 0
    @IBOutlet weak var survey1Med: UISwitch! // 1
    @IBOutlet weak var survey1High: UISwitch! // 2
    
    @IBOutlet weak var survey2Low: UISwitch!
    @IBOutlet weak var survey2Med: UISwitch!
    @IBOutlet weak var survey2High: UISwitch!
    
    @IBOutlet weak var survey3Low: UISwitch!
    @IBOutlet weak var survey3Med: UISwitch!
    @IBOutlet weak var survey3High: UISwitch!
    
    static var cards: [Card] = [] // TODO
    
    var alertController: UIAlertController?
    var meeting: Meeting!
    // var survey: Survey!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Meeting"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButton(_:)))

        // TODO
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "CardCellNib", bundle: nil), forCellReuseIdentifier: "CardCell")
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        // Existing meeting
        if nil != meeting {
            personTextField.text = meeting.personId
            notesTextView.text = meeting.notes
            
            let query = PFQuery(className: "Survey")
            query.whereKey(ObjectKeys.Survey.objectId, equalTo: meeting.surveyId)
            query.findObjectsInBackground { (surveys: [PFObject]?, error: Error?) in
                if let error = error {
                    print("Unable to find survey associated with survey id, error: \(error.localizedDescription)")
                } else {
                    if let surveys = surveys {
                        if surveys.count > 0 {
                            let survey = surveys[0]
                            
                            let survey1Value = survey[ObjectKeys.Survey.surveyValueId1] as! Int
                            if survey1Value == 0 {
                                self.survey1Low.isOn = true
                            } else if survey1Value == 1 {
                                self.survey1Med.isOn = true
                            } else if survey1Value == 2 {
                                self.survey1High.isOn = true
                            }
                            
                            let survey2Value = survey[ObjectKeys.Survey.surveyValueId2] as! Int
                            if survey2Value == 0 {
                                self.survey2Low.isOn = true
                            } else if survey2Value == 1 {
                                self.survey2Med.isOn = true
                            } else if survey2Value == 2 {
                                self.survey2High.isOn = true
                            }
                            
                            let survey3Value = survey[ObjectKeys.Survey.surveyValueId3] as! Int
                            if survey3Value == 0 {
                                self.survey3Low.isOn = true
                            } else if survey3Value == 1 {
                                self.survey3Med.isOn = true
                            } else if survey3Value == 2 {
                                self.survey3High.isOn = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /*func onAddButton(_ sender: UIBarButtonItem) {
        guard MeetingDetailsViewController.cards.count != Constants.dashboardCards.count else {
            alertController?.message = "You already have all the cards"
            present(alertController!, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectionNavigationController = storyboard.instantiateViewController(withIdentifier: "SelectionNavigationController") as! UINavigationController
        
        /*if let selectionViewController = selectionNavigationController.topViewController as? SelectionViewController {
            selectionViewController.delegate = self
            selectionViewController.selectionType = "meeting"
        }*/
        
        present(selectionNavigationController, animated: true, completion: nil)
    }*/
    
    func onSaveButton(_ sender: UIBarButtonItem) {
        
        let query = PFQuery(className: "Person")
        let firstName = personTextField.text! as String
        query.whereKey("firstName", equalTo: firstName)
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) -> Void in
            if let posts = posts {
                let person = posts[0]
                let personId = person.objectId
        
                debugPrint("no of items in posts: \(posts.count)")
                for post in posts {
                    debugPrint("post contains \(post.objectId!)")
                }
                
                
        // Survey
        let post = PFObject(className: "Survey")
        post["surveyDesc1"] = "happiness"
        post["surveyValueId1"] = (self.survey1Low.isOn ? 0 : (self.survey1High.isOn ? 2 : 1))
        post["surveyDesc2"] = "engagement"
        post["surveyValueId2"] = (self.survey2Low.isOn ? 0 : (self.survey2High.isOn ? 2 : 1))
        post["surveyDesc3"] = "workload"
        post["surveyValueId3"] = (self.survey3Low.isOn ? 0 : (self.survey3High.isOn ? 2 : 1))
        post.saveInBackground(block: { (success: Bool, error: Error?) in
            
            if success {
                ParseClient.sharedInstance().getCurrentPerson(completion: { (person: PFObject?, error: Error?) in
                    if let person = person {
                        let managerId = person.objectId
                        
                        let dictionary: [String: Any] = [
                            "personId": personId, // TODO
                            "managerId": managerId,
                            "surveyId": post.objectId!,
                            "meetingDate": Date(),
                            "notes": self.notesTextView.text
                        ]
                        self.meeting = Meeting(dictionary: dictionary)
                        print("survey saved successfully")
                        
                        Meeting.saveMeetingToParse(meeting: self.meeting) { (success: Bool, error: Error?) in
                            if success {
                                print("Successfully saved meeting")
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                self.alertController?.message = "Meeting was unable to be saved"
                                self.present(self.alertController!, animated: true)
                            }
                        }
                    }
                })
            }
        })
        
            }
        }
        
    }
    
    // MARK: - IBAction
    
    @IBAction func onSurvey1LowSwitch(_ sender: AnyObject) {
        // survey1Low.isOn = !survey1Low.isOn not working properly
        
        if survey1Low.isOn {
            survey1Med.isOn = false
            survey1High.isOn = false
        }
    }
    
    @IBAction func onSurvey1MedSwitch(_ sender: AnyObject) {
        if survey1Med.isOn {
            survey1Low.isOn = false
            survey1High.isOn = false
        }
    }
    
    @IBAction func onSurvey1HighSwitch(_ sender: AnyObject) {
        if survey1High.isOn {
            survey1Low.isOn = false
            survey1Med.isOn = false
        }
    }
    
    @IBAction func onSurvey2LowSwitch(_ sender: AnyObject) {
        if survey2Low.isOn {
            survey2Med.isOn = false
            survey2High.isOn = false
        }
    }
    
    @IBAction func onSurvey2MedSwitch(_ sender: AnyObject) {
        if survey2Med.isOn {
            survey2Low.isOn = false
            survey2High.isOn = false
        }
    }
    
    @IBAction func onSurvey2HighSwitch(_ sender: AnyObject) {
        if survey2High.isOn {
            survey2Low.isOn = false
            survey2Med.isOn = false
        }
    }
    
    @IBAction func onSurvey3LowSwitch(_ sender: AnyObject) {
        if survey3Low.isOn {
            survey3Med.isOn = false
            survey3High.isOn = false
        }
    }
    
    @IBAction func onSurvey3MedSwitch(_ sender: AnyObject) {
        if survey3Med.isOn {
            survey3Low.isOn = false
            survey3High.isOn = false
        }
    }
    
    @IBAction func onSurvey3HighSwitch(_ sender: AnyObject) {
        if survey3High.isOn {
            survey3Low.isOn = false
            survey3Med.isOn = false
        }
    }
}

// MARK: - SelectionViewControllerDelegate

/*extension MeetingDetailsViewController: SelectionViewControllerDelegate {
    
    func selectionViewController(selectionViewController: SelectionViewController, didAddDashboardCard card: Card) {
        // Do nothing
    }
    
    func selectionViewController(selectionViewController: SelectionViewController, didRemoveDashboardCard card: Card) {
        // Do nothing
    }
    
    func selectionViewController(selectionViewController: SelectionViewController, didAddMeetingCard card: Card) {
        // Insert new card at the top of the table view
        MeetingDetailsViewController.cards.insert(card, at: 0)
        tableView.reloadData()
    }
    func selectionViewController(selectionViewController: SelectionViewController, didRemoveMeetingCard card: Card) {
        // Remove card from table view
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id {
                MeetingDetailsViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}
*/
// MARK: - UITableViewDataSource

extension MeetingDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MeetingDetailsViewController.cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // No cards
        if MeetingDetailsViewController.cards.count == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell
            if nil == cell {
                cell = UITableViewCell(style: .default, reuseIdentifier: "MessageCell") as? MessageCell
            }
            cell?.message = "Tap the + button to add cards"
            cell?.isUserInteractionEnabled = false
            return cell!
            
            // Last section
        } else if indexPath.section == numberOfSections(in: tableView) - 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell
            if nil == cell {
                cell = UITableViewCell(style: .default, reuseIdentifier: "MessageCell") as? MessageCell
            }
            cell?.message = "Tap the + button to add cards"
            cell?.isUserInteractionEnabled = false
            return cell!
        
            // TODO replace the cells with the actual view
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as? CardCell
            if nil == cell {
                cell = (UITableViewCell(style: .default, reuseIdentifier: "CardCell") as? CardCell)!
            }
            cell?.delegate = self
            cell?.card = MeetingDetailsViewController.cards[indexPath.section]
            return cell!
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MeetingDetailsViewController.cards.count + 2
    }
}

extension MeetingDetailsViewController: UITableViewDelegate {
}

// MARK: - CardCellDelegate

extension MeetingDetailsViewController: CardCellDelegate {
    func cardCell(cardCell: CardCell, didMoveUp card: Card) {
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id {
                
                // First card
                guard index != 0 else {
                    alertController?.message = "This card cannot move up further"
                    present(alertController!, animated: true)
                    return
                }
                
                // Swap with card before
                let cardBefore = MeetingDetailsViewController.cards[index-1]
                MeetingDetailsViewController.cards[index-1] = card
                MeetingDetailsViewController.cards[index] = cardBefore
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didMoveDown card: Card) {
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id { // TODO find better way to do this
                
                // Last card
                guard index < MeetingDetailsViewController.cards.count - 1 else {
                    alertController?.message = "This card cannot move down further"
                    present(alertController!, animated: true)
                    return
                }
                
                // Swap with card after
                let cardAfter = MeetingDetailsViewController.cards[index+1]
                MeetingDetailsViewController.cards[index+1] = card
                MeetingDetailsViewController.cards[index] = cardAfter
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didDelete card: Card) {
        // Remove card from table view
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id {
                MeetingDetailsViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}

