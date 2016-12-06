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
    @IBOutlet weak var seeAllButton: UIButton! // See All Button
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var meetingsLabel: UILabel!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
    
    var meetings: [Meeting] = []
    var expanded = false
    var personId: String?
    var viewTypes: ViewTypes = .dashboard // Default
    
    fileprivate let parseClient = ParseClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meetings"

        if expanded {
            UIExtensions.gradientBackgroundFor(view: view)
            navigationController?.navigationBar.barStyle = .blackTranslucent
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButton(_:)))
        }
        
        tableView.isScrollEnabled = expanded
        //seeAllButton.isHidden = expanded
        addButton.isHidden = expanded
        meetingsLabel.isHidden = expanded
        
        tableViewTopConstraint.constant = expanded ? 8 : 75
        tableViewTrailingConstraint.constant = expanded ? 8 : 0
        tableViewTrailingConstraint.constant = expanded ? 8 : 16
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 5
        
        //tableView.register(UINib(nibName: "CustomTextCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
        tableView.register(UINib(nibName: "MeetingListCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
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
                
                if self.personId != nil,
                    let personId = self.personId {
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
        // Calculated with bottom-most element (y position + displayed rows height - status bar height)
        //return 95 + (56 * 3) - 20
        return 95 + (56 * 3) - 20 + 30
    }
    
    // MARK: - IBAction
    
    @IBAction func onSeeAllButton(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingsViewController") as! MeetingsViewController
        viewController.expanded = true
        viewController.personId = personId
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func onAddButton(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsViewController") as! MeetingDetailsViewController
        viewController.isExistingMeeting = false
        
        // If adding meeting from a Person page
        if self.viewTypes == .employeeDetail {
            viewController.viewTypes = .employeeDetail
            
            if let personId = self.personId {
                parseClient.fetchPersonFor(personId: personId) { (person: PFObject?, error: Error?) in
                    if let error = error {
                        debugPrint("Failed to fetch teamMember, error: \(error.localizedDescription)")
                        self.navigationController?.pushViewController(viewController, animated: true)
                    } else {
                        viewController.teamMember = person
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            } else {
                navigationController?.pushViewController(viewController, animated: true)
            }
        } else { // From Dashboard
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension MeetingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 0 < meetings.count {
            //let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! CustomTextCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! MeetingListCell
            //selectAllButton.isHidden = false
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let meetingDate = formatter.string(from: meetings[indexPath.row].meetingDate)
            
            let personQuery = PFQuery(className: "Person")
            personQuery.whereKey(ObjectKeys.Person.objectId, equalTo: meetings[indexPath.row].personId)
            personQuery.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
                if let persons = persons {
                    let person = persons[0]
                    if let firstName = person[ObjectKeys.Person.firstName] as? String, let lastName = person[ObjectKeys.Person.lastName] as? String {
                        cell.message = firstName != lastName ? "\(firstName) \(lastName)" : firstName
                        cell.submessage = "\(meetingDate)"
                        cell.imageName = "Clipboard"
                        
                        self.parseClient.fetchSurveyFor(surveyId: self.meetings[indexPath.row].surveyId, isAscending: nil, orderBy: nil) { (survey: PFObject?, error: Error?) in
                            if let error = error {
                                debugPrint("Failed to fetch survey, error: \(error.localizedDescription)")
                                cell.survey = nil
                            } else {
                                cell.survey = survey
                            }
                        }
                    }
                }
            }
            
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        //seeAllButton.isHidden = true
        cell.textLabel?.text = "You currently have no meetings"
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
                            //self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success", message: "Successfully deleted meeting")
                            print("Successfully deleted meeting")
                            self.loadMeetings()
                        } else {
                            if let error = error {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error deleting meeting, error: \(error.localizedDescription)")
                            } else {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error deleting meeting")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

extension MeetingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard 0 < meetings.count else {
            print("No meetings")
            return
        }
        
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsViewController") as! MeetingDetailsViewController
        viewController.meeting = meetings[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}
