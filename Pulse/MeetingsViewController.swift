//
//  MeetingsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/11/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit

class MeetingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var meetings: [Meeting] = []
    var expanded = false
    
    var personId: String? // Employee ID - TODO - Ale, when adding this to person details, set this parameter
    
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Meetings"

        selectAllButton.isHidden = expanded
        addButton.isHidden = expanded
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMeetings()
    }
    
    func loadMeetings() {
        // Reset meetings
        meetings = []
        
        ParseClient.sharedInstance().getCurrentPerson { (person: PFObject?, error: Error?) in
            if let person = person {
                
                let query = PFQuery(className: "Meetings")
                
                let managerId = person.objectId! as String
                query.whereKey("managerId", equalTo: managerId)
                query.whereKeyDoesNotExist("deletedAt")
                query.order(byDescending: "meetingDate")
                
                if let personId = self.personId {
                    query.whereKey("personId", equalTo: personId)
                }
                
                if !self.expanded {
                    query.limit = 3
                }
                
                query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                    if let posts = posts {
                        for post in posts {
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            if let meetingDateString = post["meetingDate"] as? String,
                                let meetingDate = dateFormatter.date(from: meetingDateString) {
                                
                                // TODO remove this chunk later, where meetingDate is string
                                let dictionary = [
                                    "objectId": post.objectId as Any,
                                    "personId": post["personId"],
                                    "managerId": post["managerId"],
                                    "surveyId": post["surveyId"],
                                    "meetingDate": meetingDate,
                                    "notes": post["notes"],
                                    "selectedCards": (nil != post["selectedCards"] ? post["selectedCards"] : "") as Any
                                ]
                                
                                let meeting = Meeting(dictionary: dictionary)
                                self.meetings.append(meeting)
                            }
                            
                            if let meetingDate = post["meetingDate"] as? Date {
                                let dictionary = [
                                    "objectId": post.objectId as Any,
                                    "personId": post["personId"],
                                    "managerId": post["managerId"],
                                    "surveyId": post["surveyId"],
                                    "meetingDate": meetingDate,
                                    "notes": (nil != post["notes"] ? post["notes"] : ""),
                                    "selectedCards": (nil != post["selectedCards"] ? post["selectedCards"] : "") as Any
                                ]
                                
                                let meeting = Meeting(dictionary: dictionary)
                                self.meetings.append(meeting)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func heightForView() -> CGFloat {
        return 44*4 // TODO
    }
    
    // MARK: - IBAction
    
    @IBAction func onSeeAllButton(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingsViewController") as! MeetingsViewController
        viewController.expanded = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func onAddButton(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsViewController") as! MeetingDetailsViewController
        viewController.isExistingMeeting = false
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MeetingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        if 0 < meetings.count {
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let meetingDate = formatter.string(from: meetings[indexPath.row].meetingDate)
            
            let personQuery = PFQuery(className: "Person")
            personQuery.whereKey(ObjectKeys.Person.objectId, equalTo: meetings[indexPath.row].personId)
            personQuery.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
                if let persons = persons,
                    let person = persons[0] as? PFObject,
                    let personName = person["firstName"] as? String {
                    cell.messageLabel.text = "\(personName) (\(meetingDate))"
                }
            }
            cell.accessoryType = .disclosureIndicator

        } else {
            cell.messageLabel.text = "You have no meetings"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (0 < meetings.count ? meetings.count : 1)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // Update parse
            let query = PFQuery(className: "Meetings")
            let meeting = meetings[indexPath.row]
               if let meetingId = meeting.objectId {
                query.whereKey("objectId", equalTo: meetingId)
            }
            
            query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                if let posts = posts {
                    let post = posts[0]
                    post["deletedAt"] = Date()
                    post.saveInBackground { (success: Bool, error: Error?) in
                        if success {
                            //self.alertController?.message = "Successfully deleted meeting."
                            //self.present(self.alertController!, animated: true)
                            print("Successfully deleted meeting")
                            self.loadMeetings()
                        } else {
                            //self.alertController?.message = "Error deleting meeting."
                            //self.present(self.alertController!, animated: true)
                            print("Error deleting meeting")
                        }
                    }
                }
            }
        }
    }
}

extension MeetingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsViewController") as! MeetingDetailsViewController
        viewController.meeting = meetings[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}
