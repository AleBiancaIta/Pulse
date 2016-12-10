//
//  TeamListViewController.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TeamListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    let dataSource = TeamViewDataSource.sharedInstance()
    var deletedPersonIndexPath: IndexPath? = nil
    var person: PFObject! = nil
    fileprivate let parseClient = ParseClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Team Members"
        
        UIExtensions.gradientBackgroundFor(view: view)
        
        tableView.register(UINib(nibName: "TeamTableViewCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Team.teamListCell)
        tableView.delegate = self
        tableView.layer.cornerRadius = 5
        tableView.isMultipleTouchEnabled = false
        
        //dataSource.delegate = self
        
        subscribeToNotifications()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonTap(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.dataSource = self.dataSource
        dataSource.delegate = self
        dataSource.fetchTeamMembersForCurrentPerson(person: self.person) { (success: Bool, error: Error?) in
            if success {
                debugPrint("successfully fetching team members")
                self.tableView.reloadData()
            } else {
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to load team data, error: \(error.localizedDescription)")
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to load team data")
                }
            }
        }
    }
    
    
    // MARK: - Actions
    
    @objc fileprivate func onAddButtonTap(_ sender: UIButton) {
		ABIShowPersonViewController(personPFObject: nil)
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    @objc fileprivate func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(addTeamMemberSuccessful(notification:)), name: NSNotification.Name(rawValue: Notifications.Team.addTeamMemberSuccessful), object: nil)
    }
    
    @objc fileprivate func addTeamMemberSuccessful(notification: NSNotification) {
        debugPrint("Get notifications: add team member successful")
        // refresh and reload data
    }
}

extension TeamListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Person2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Person2DetailsViewController") as! Person2DetailsViewController
        
        let person = dataSource.getSelectedPersonObjectAt(indexPath: indexPath)
        viewController.personPFObject = person
        
        if let person = person {
            dataSource.isPersonManager(personId: person.objectId!, isDeleted: false) { (isManager: Bool, error: Error?) in
                if let error = error {
                    debugPrint("in TeamListVC isPersonManager returned error: \(error.localizedDescription)")
                    viewController.isPersonManager = false
                } else {
                    if isManager {
                        viewController.isPersonManager = true
                    } else {
                        viewController.isPersonManager = false
                    }
                }
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            debugPrint("in TeamListVC person is nil")
        }
    }
}

extension TeamListViewController: TeamViewDataSourceDelegate {
    
    func teamViewDataSource(_ teamViewDataSource: TeamViewDataSource, at indexPath: IndexPath) {
        deletedPersonIndexPath = indexPath
        let _ = dataSource.getSelectedPersonObjectAt(indexPath: indexPath)
        //let personToDelete = dataSource.getSelectedPersonObjectAt(indexPath: indexPath)
        //confirmDelete(person: personToDelete!)
        handleDeletingPerson()
    }
    
    func teamViewDataSource(_ teamViewDataSource: TeamViewDataSource, surveyButtonTap survey: PFObject) {
        debugPrint("survey button tapped, \(survey)")
        
        // fetch meeting object associated with the survey
        parseClient.fetchMeetingFor(surveyId: survey.objectId!, isDeleted: false) { (meeting: PFObject?, error: Error?) in
            if let error = error {
                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to fetch meeting survey, error: \(error.localizedDescription)")
            } else {
                if let meeting = meeting {
                    
                    let personId = meeting[ObjectKeys.Meeting.personId] as! String
                    self.parseClient.fetchPersonFor(personId: personId) { (teamMember: PFObject?, error: Error?) in
                        if let error = error {
                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to fetch survey person, error: \(error.localizedDescription)")
                        } else {
                            if let teamMember = teamMember {
                                self.segueToMeetingDetailsVC(meeting: meeting, person: teamMember)
                            } else {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Couldn't find the team member associated with survey")
                            }
                        }
                    }
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Couldn't find meeting associated with survey")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func segueToMeetingDetailsVC(meeting: PFObject, person: PFObject) {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsViewController") as! MeetingDetailsViewController
        viewController.meeting = Meeting(meeting: meeting)
        viewController.teamMember = person
        viewController.isExistingMeeting = true
        viewController.viewTypes = .employeeDetail
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func confirmDelete(person: PFObject) {
        ABIShowAlertWithActions(title: "", message: "Are you sure you want to delete this person?", actionTitle1: "Confirm", actionTitle2: "Cancel", sender: nil, handler1: { (alertAction:UIAlertAction) in
            if alertAction.title == "Confirm" {
                self.handleDeletingPerson()
            }
        }, handler2: { (alertAction: UIAlertAction) in
            if alertAction.title == "Cancel" {
                self.cancelDeletingPerson()
            }
        })
    }
    
    fileprivate func handleDeletingPerson() {
        if let indexPath = deletedPersonIndexPath {
            dataSource.removeSelectedPersonObjectAt(indexPath: indexPath) { (success: Bool, error: Error?) in
                if success {
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.deletedPersonIndexPath = nil
                    self.tableView.endUpdates()
                } else {
                    debugPrint("\(error?.localizedDescription)")
                }
            }
        }
    }
    
    fileprivate func cancelDeletingPerson() {
        tableView.reloadRows(at: [deletedPersonIndexPath!], with: .none)
        deletedPersonIndexPath = nil
    }
}



