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
    
    var selectedCardsString: String = ""
    var selectedCards: [Card] = [Constants.meetingCards[0]] // Always include survey card
    
    var meeting: Meeting!
    var isExistingMeeting = true // False if new meeting, otherwise true
    
    fileprivate let parseClient = ParseClient.sharedInstance()
    weak var delegate: MeetingDetailsViewControllerDelegate?
    weak var delegate2: MeetingDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        UIExtensions.gradientBackgroundFor(view: view)
        navigationController?.navigationBar.barStyle = .blackTranslucent
      
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButton(_:)))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "CustomTextCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
        tableView.register(UINib(nibName: "CardManagementCell", bundle: nil), forCellReuseIdentifier: "AddCardCell")
      
        alertController = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        loadSelectedCards()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.size.height = UIScreen.main.bounds.height - keyboardSize.height - 64
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.size.height = UIScreen.main.bounds.height - 64
    }
    
    func loadSelectedCards() {
        
        // Existing meeting
        if nil != meeting {
            if let selectedCardsString = meeting.selectedCards {
                self.selectedCardsString = selectedCardsString
                for c in (meeting.selectedCards?.characters)! {
                    switch c {
                    case "d":
                        if !self.selectedCards.contains(Constants.meetingCards[1]) {
                            selectedCards.append(Constants.meetingCards[1])
                        }
                    case "n":
                        if !self.selectedCards.contains(Constants.meetingCards[2]) {
                           selectedCards.append(Constants.meetingCards[2])
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func onSaveButton(_ sender: UIBarButtonItem) {
        debugPrint("Save button tap")
        delegate?.meetingDetailsViewController?(self, onSave: true)
        delegate2?.meetingDetailsViewController?(self, onSave: true)
    }
    
    func onManageCards() {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsSelectionViewController") as! MeetingDetailsSelectionViewController
        viewController.delegate = self
        viewController.selectedCards = selectedCards
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension MeetingDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == selectedCards.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardCell", for: indexPath) as! CardManagementCell
            cell.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
         
            if isExistingMeeting {
                cell.addButton.tintColor = UIColor.pulseAccentColor()
                cell.manageLabel.tintColor = UIColor.pulseAccentColor()
                cell.addButton.addTarget(self, action: #selector(onManageCards), for: .touchUpInside)
            } else {
               cell.addButton.tintColor = UIColor.lightGray
               cell.manageLabel.textColor = UIColor.lightGray
                cell.manageLabel.text = "Save meeting to manage modules"
            }
            return cell
            
        } else { // The actual cards
            switch selectedCards[indexPath.section].id! {
            case "s":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyContainerCell", for: indexPath)
                cell.layer.cornerRadius = 5
                cell.selectionStyle = .none
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardID.meetingSurveyVC) as! MeetingSurveyViewController
                    viewController.meeting = meeting
                    viewController.isExistingMeeting = isExistingMeeting
                    viewController.delegate = self
                    self.delegate = viewController
                    
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                return cell
                
            case "d":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoContainerCell", for: indexPath)
                cell.layer.cornerRadius = 5
                cell.selectionStyle = .none
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Todo", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
                    viewController.currentMeeting = meeting
                    viewController.viewTypes = .meeting
                    
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                
                return cell
                
            case "n":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotesContainerCell", for: indexPath)
                cell.layer.cornerRadius = 5
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor.clear
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Notes", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
                    viewController.delegate = self
                    self.delegate2 = viewController
                    viewController.notes = meeting.notes
                    
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                
                return cell
                
            default: // This shouldn't actually be reached
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! CustomTextCell
                cell.message = selectedCards[indexPath.section].name
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedCards.count + 1
    }
}

// MARK: - UITableViewDelegate

extension MeetingDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let defaultHeight: CGFloat = 44
        guard indexPath.section < selectedCards.count else {
            return defaultHeight
        }
        
        switch selectedCards[indexPath.section].id! {
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
        
        if indexPath.section == selectedCards.count && isExistingMeeting {
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
                let id = card.id {
                
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = "\(id)\(self.selectedCardsString)"
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground { (success: Bool, error: Error?) in
                        if success {
                            print("successfully saved meeting cards")
                        } else {
                            print("error saving meeting cards")
                        }
                    }
                } else {
                    let post = PFObject(className: "Meetings")
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground()
                }
            } else {
                print("error saving meeting cards")
            }
        }
        
        // Insert new card at the top of the table view
        if !selectedCards.contains(card) {
            selectedCards.insert(card, at: 1)
        }
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
                let id = card.id {
                
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = self.selectedCardsString.replacingOccurrences(of: id, with: "")
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
        } else {
            // save notes in case it's changed
            saveExistingMeeting(meeting: meeting)
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
        meeting.selectedCards = self.selectedCardsString
        Meeting.saveMeetingToParse(meeting: meeting) { (success: Bool, error: Error?) in
            if success {
                self.parseClient.fetchMeetingFor(personId: meeting.personId, managerId: meeting.managerId, surveyId: meeting.surveyId, isDeleted: false) { (meetingObject: PFObject?, error: Error?) in
                    if let error = error {
                        debugPrint("Failed to fetch newly saved meeting, error: \(error.localizedDescription)")
                    } else {
                        self.meeting = meeting
                        self.meeting.objectId = meetingObject?.objectId
                        self.isExistingMeeting = true
                        self.tableView.reloadData()
                        self.alertController?.message = "Successfully saved meeting."
                        self.present(self.alertController!, animated: true)
                    }
                }
            } else {
                self.alertController?.message = "Meeting was unable to be saved"
                self.present(self.alertController!, animated: true)
            }
        }
    }
}
