//
//  MeetingDetailsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit

@objc protocol MeetingDetailsViewControllerDelegate {
    @objc optional func meetingDetailsViewController(_ meetingDetailsViewController: MeetingDetailsViewController, onSave: Bool)
}

class MeetingDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var alertController: UIAlertController?
    
    var selectedCardsString: String? = ""
    var selectedCards: [Card] = []
    
    var meeting: Meeting!
    var isExistingMeeting = true // False if new meeting, otherwise true
    
    fileprivate let parseClient = ParseClient.sharedInstance()
    weak var delegate: MeetingDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meeting"
        
        /*
        if !isExistingMeeting {
            personTextField.isUserInteractionEnabled = true
        } else {
            personTextField.isUserInteractionEnabled = false
        }*/
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButton(_:)))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        alertController = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        if !isExistingMeeting {
            selectedCards.append(Constants.meetingCards[0])
        }
        
        //loadExistingMeeting()
        loadSelectedCards()
    }
    
    @objc fileprivate func resetCell(_ cell: UITableViewCell) {
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    //func loadExistingMeeting() {
    
    func loadSelectedCards() {
        // Existing meeting
        if nil != meeting {
            
            /*
            let personQuery = PFQuery(className: "Person")
            personQuery.whereKey(ObjectKeys.Person.objectId, equalTo: meeting.personId)
            personQuery.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
                if let error = error {
                    print("Unable to find survey associated with survey id, error: \(error.localizedDescription)")
                } else {
                    if let persons = persons {
                        let person = persons[0]
                        //self.personTextField.text = person["firstName"] as? String
                    }
                }
            }*/
            
            // THIS ONE NEED TO STAY HERE
            if let selectedCardsString = meeting.selectedCards {
                self.selectedCardsString = selectedCardsString
                for c in (meeting.selectedCards?.characters)! {
                    switch c {
                    case "s":
                        selectedCards.append(Constants.meetingCards[0])
                    case "d":
                        selectedCards.append(Constants.meetingCards[1])
                    case "n":
                        selectedCards.append(Constants.meetingCards[2])
                    //case "p":
                    //    selectedCards.append(Constants.meetingCards[2])
                    default:
                        break
                    }
                }
            }
            
            /*
            let query = PFQuery(className: "Survey")
            query.whereKey(ObjectKeys.Survey.objectId, equalTo: meeting.surveyId)
            query.findObjectsInBackground { (surveys: [PFObject]?, error: Error?) in
                if let error = error {
                    print("Unable to find survey associated with survey id, error: \(error.localizedDescription)")
                } else {
                    if let surveys = surveys {
                        if surveys.count > 0 {
                            let survey = surveys[0]
             
                            // Reset
                            self.survey1Med.isOn = false
                            self.survey2Med.isOn = false
                            self.survey3Med.isOn = false
                            
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
            }*/
        }
    }
    
    func onSaveButton(_ sender: UIBarButtonItem) {
        debugPrint("Save button tap")
        delegate?.meetingDetailsViewController?(self, onSave: true)
    }
    
    func onManageCards() {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsSelectionViewController") as! MeetingDetailsSelectionViewController
        viewController.delegate = self
        viewController.selectedCards = selectedCards
        let navController = UINavigationController(rootViewController: viewController)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension MeetingDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == selectedCards.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            if isExistingMeeting {
                cell.message = "Tap here to manage cards"
            } else {
                cell.message = "Save meeting to manage cards"
            }
            return cell
            
        } else { // The actual cards
            switch selectedCards[indexPath.row].id! {
            case "s":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                resetCell(cell)
                let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardID.meetingSurveyVC) as! MeetingSurveyViewController
                viewController.meeting = meeting
                viewController.isExistingMeeting = isExistingMeeting
                viewController.delegate = self
                self.delegate = viewController
                cell.contentView.addSubview(viewController.view)
                self.addChildViewController(viewController)
                viewController.didMove(toParentViewController: self)
                return cell
                
            case "d":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoContainerCell", for: indexPath)
                cell.selectionStyle = .none
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Todo", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
                    viewController.currentMeeting = meeting
                    viewController.viewTypes = .meeting
                    viewController.willMove(toParentViewController: self)
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                
                return cell
                
            case "n":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotesContainerCell", for: indexPath)
                cell.selectionStyle = .none
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Notes", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
                    viewController.delegate = self
                    viewController.notes = meeting.notes
                    viewController.willMove(toParentViewController: self)
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                
                return cell
                
            default: // This shouldn't actually be reached
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
                cell.message = selectedCards[indexPath.row].name
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCards.count + 1
    }
}

// MARK: - UITableViewDelegate

extension MeetingDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let defaultHeight: CGFloat = 44
        guard indexPath.row < selectedCards.count else {
            return defaultHeight
        }
        
        switch selectedCards[indexPath.row].id! {
        case "s":
            let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardID.meetingSurveyVC) as! MeetingSurveyViewController
            return viewController.heightForView()
            
        case "d":
            let storyboard = UIStoryboard(name: "Todo", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
            return viewController.heightForView()
        
        case "n":
            let storyboard = UIStoryboard(name: "Notes", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
            return viewController.heightForView()
            
        default:
            return defaultHeight
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == selectedCards.count && isExistingMeeting {
            onManageCards()
        }
    }
}

// MARK: - MeetingDetailsSelectionViewControllerDelegate

extension MeetingDetailsViewController: MeetingDetailsSelectionViewControllerDelegate {
    
    func meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: MeetingDetailsSelectionViewController, didAddCard card: Card) {
        let query = PFQuery(className: "Meetings")
        if let meetingId = meeting.objectId {
            query.whereKey("objectId", equalTo: meetingId)
        }
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = "\(id)\(selectedCardsString)"
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground { (success: Bool, error: Error?) in
                        if success {
                            print("successfully saved meeting card")
                        } else {
                            print("error saving meeting card")
                        }
                    }
                } else {
                    let post = PFObject(className: "Meetings")
                    post["selectedCards"] = selectedCardsString
                    post.saveInBackground()
                }
            } else {
                print("error saving meeting card")
            }
        }
        
        // Insert new card at the top of the table view
        selectedCards.insert(card, at: 0)
        tableView.reloadData()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
    }
    
    func meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: MeetingDetailsSelectionViewController, didRemoveCard card: Card) {
        
        let query = PFQuery(className: "Meetings")
        if let meetingId = meeting.objectId {
            query.whereKey("objectId", equalTo: meetingId)
        }
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = selectedCardsString.replacingOccurrences(of: id, with: "")
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground { (success: Bool, error: Error?) in
                        print("successfully removed meeting card")
                    }
                }
            } else {
                print("error removing meeting card")
            }
        }
        
        // Remove card from table view
        for (index, meetingCard) in selectedCards.enumerated() {
            if meetingCard.id == card.id {
                selectedCards.remove(at: index)
            }
        }
        tableView.reloadData()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
    }
}

extension MeetingDetailsViewController: NotesViewControllerDelegate {
    func notesViewController(notesViewController: NotesViewController, didUpdateNotes notes: String) {
        meeting.notes = notes
    }
}

extension MeetingDetailsViewController: MeetingSurveyViewControllerDelegate {
    func meetingSurveyViewController(_ meetingSurveyViewController: MeetingSurveyViewController, meeting: Meeting, surveyChanged: Bool) {
        if surveyChanged {
            if isExistingMeeting {
                saveExistingMeeting(meeting: meeting)
            } else {
                saveNewMeeting(meeting: meeting)
            }
        }
    }
    
    fileprivate func saveExistingMeeting(meeting: Meeting) {
        parseClient.fetchMeetingFor(meetingId: meeting.objectId!) { (meeting: PFObject?, error: Error?) in
            if let meeting = meeting {
                meeting[ObjectKeys.Meeting.notes] = self.meeting.notes
                meeting[ObjectKeys.Meeting.selectedCards] = self.selectedCardsString
                meeting.saveInBackground { (success: Bool, error: Error?) in
                    if success {
                        self.isExistingMeeting = true
                        self.tableView.reloadData()
                        self.alertController?.message = "Successfully saved meeting"
                        self.present(self.alertController!, animated: true)
                    } else {
                        self.alertController?.message = "Meeting was unable to be saved"
                        self.present(self.alertController!, animated: true)
                    }
                }
            } else {
                debugPrint("Failed to fetch meeting, error: \(error?.localizedDescription)")
            }
        }
    }

    fileprivate func saveNewMeeting(meeting: Meeting) {
        Meeting.saveMeetingToParse(meeting: meeting) { (success: Bool, error: Error?) in
            if success {
                self.isExistingMeeting = true
                self.tableView.reloadData()
                self.alertController?.message = "Successfully saved meeting."
                self.present(self.alertController!, animated: true)
            } else {
                self.alertController?.message = "Meeting was unable to be saved"
                self.present(self.alertController!, animated: true)
            }
        }
    }
}
    /*
        ParseClient.sharedInstance().getCurrentPerson(completion: { (person: PFObject?, error: Error?) in
            if let userPerson = person {
                let query = PFQuery(className: "Person")
                let firstName = self.personTextField.text! as String
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
                        post["companyId"] = userPerson["companyId"]
                        post["meetingDate"] = Date()
                        post["personId"] = personId
                        post.saveInBackground(block: { (success: Bool, error: Error?) in
                            
                            if success {
                                let managerId = userPerson.objectId
                                let dictionary: [String: Any] = [
                                    "personId": personId as Any,
                                    "managerId": managerId as Any,
                                    "surveyId": post.objectId!,
                                    "meetingDate": Date()
                                ]
                                self.meeting = Meeting(dictionary: dictionary)
                                print("survey saved successfully")
                                
                                Meeting.saveMeetingToParse(meeting: self.meeting) { (success: Bool, error: Error?) in
                                    if success {
                                        self.isExistingMeeting = true
                                        self.personTextField.isUserInteractionEnabled = false
                                        self.tableView.reloadData()
                                        self.alertController?.message = "Successfully saved meeting."
                                        self.present(self.alertController!, animated: true)
                                    } else {
                                        self.alertController?.message = "Meeting was unable to be saved"
                                        self.present(self.alertController!, animated: true)
                                    }
                                }
                            } else {
                                self.alertController?.message = "Meeting was unable to be saved"
                                self.present(self.alertController!, animated: true)
                            }
                        })
                    }
                }
            }
        })
    }*/
