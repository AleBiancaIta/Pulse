//
//  TeamCollectionViewController.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TeamCollectionViewController: UIViewController {
    
    @IBOutlet weak var noTeamMembersLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = TeamViewDataSource.sharedInstance()
    var person: PFObject! = nil
    fileprivate let parseClient = ParseClient.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Team Members"

        collectionView.register(UINib(nibName: "TeamCollectionCell", bundle: nil), forCellWithReuseIdentifier: CellReuseIdentifier.Team.teamCollectionCell)
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.isMultipleTouchEnabled = false
        subscribeToNotifications()
//        dataSource.delegate = self
//        dataSource.printTeamMembers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.dataSource = self.dataSource
        dataSource.delegate = self
        //dataSource.printTeamMembers()

        dataSource.fetchTeamMembersForCurrentPerson(person: self.person) { (success: Bool, error: Error?) in
            if success {
                debugPrint("successfully fetching team members")
                self.noTeamMembersLabel.isHidden = !(self.dataSource.teamMembers.count == 0)
                //self.seeAllButton.isHidden = self.dataSource.teamMembers.count == 0
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
                
            } else {
                //debugPrint("Unable to load data with error: \(error?.localizedDescription)")
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to load team data, error: \(error.localizedDescription)")
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to load team data")
                }
                //self.showAlert(title: "Error", message: "Unable to load data", sender: nil, handler: nil)
            }
        }
    }
    
    func heightForView() -> CGFloat {
        // Calculated with bottom-most element (y position + height)
        return 99 + 200
    }

    // MARK: - Actions
    
    @IBAction func onAddButtonTap(_ sender: UIButton) {
		ABIShowPersonViewController(personPFObject: nil)
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("team collection view controller being deinitialized")
    }
    
    // MARK: - Helpers
    @objc fileprivate func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(addTeamMemberSuccessful(notification:)), name: NSNotification.Name(rawValue: Notifications.Team.addTeamMemberSuccessful), object: nil)
    }
    
    @objc fileprivate func addTeamMemberSuccessful(notification: NSNotification) {
        debugPrint("Get notifications: add team member successful")
		collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.seeAllTeamList {
            let destinationVC = segue.destination as! TeamListViewController
            destinationVC.person = self.person            
        }
    }
}

extension TeamCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 145.0, height: 210.0)
        //return CGSize(width: 155.0, height: 300) //height: 210.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Person2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Person2DetailsViewController") as! Person2DetailsViewController
        let person = dataSource.getSelectedPersonObjectAt(indexPath: indexPath)
        viewController.personPFObject = person
        
        if let person = person {
            dataSource.isPersonManager(personId: person.objectId!, isDeleted: false) { (isManager: Bool, error: Error?) in
                if let error = error {
                    debugPrint("in TeamCollectionVC isPersonManager returned error: \(error.localizedDescription)")
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
            debugPrint("in TeamCollectionVC person is nil")
        }
    }
}

extension TeamCollectionViewController: TeamViewDataSourceDelegate {
    func teamViewDataSource(_ teamViewDataSource: TeamViewDataSource, surveyButtonTap survey: PFObject) {
        debugPrint("team view data source delegate called")
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
                                
                                // Cannot open meeting details for person if user is not their manager
                                    if let managerId = teamMember["managerId"] as? String {
                                    ParseClient.sharedInstance().getCurrentPerson { (person: PFObject?, error: Error?) in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        } else {
                                            if let person = person, managerId == person.objectId {
                                                self.segueToMeetingDetailsVC(meeting: meeting, person: teamMember)
                                            }
                                        }
                                    }
                                }
                                
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
    
    func segueToMeetingDetailsVC(meeting: PFObject, person: PFObject) {
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingDetailsViewController") as! MeetingDetailsViewController
        viewController.meeting = Meeting(meeting: meeting)
        viewController.teamMember = person
        viewController.isExistingMeeting = true
        viewController.viewTypes = .employeeDetail
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
