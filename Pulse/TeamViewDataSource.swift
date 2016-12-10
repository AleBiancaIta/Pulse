//
//  TeamViewDataSource.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

@objc protocol TeamViewDataSourceDelegate {
    @objc optional func teamViewDataSource(_ teamViewDataSource: TeamViewDataSource, at indexPath: IndexPath)
    @objc optional func teamViewDataSource(_ teamViewDataSource: TeamViewDataSource, surveyButtonTap survey: PFObject)
}

class TeamViewDataSource: NSObject {
    
    // MARK: - Properties
    
    var parseClient = ParseClient.sharedInstance()
    //var teamMembers = [Person]()
    var teamMembers = [PFObject]()
    //var meetings = [Meeting]()
    var currentPerson: PFObject?
    
    weak var delegate: TeamViewDataSourceDelegate?
    
    // MARK: - Shared instance
    class func sharedInstance() -> TeamViewDataSource {
        struct Singleton {
            static var sharedInstance = TeamViewDataSource()
        }
        return Singleton.sharedInstance
    }
    
    func printTeamMembers() {
        for member in teamMembers {
            print("in teamViewDataSource, \(member)")
        }
    }
    
    deinit {
        print("team view data source deinitialized")
    }
    
    func fetchTeamMembersForCurrentPerson(person: PFObject?, completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        self.teamMembers.removeAll() // reset the datasource
        
        if person == nil { // In Dashboard
            parseClient.getCurrentPerson { (person: PFObject?, error: Error?) in
                if let error = error {
                    completion(false, error)
                } else {
                    if let person = person {
                        self.currentPerson = person
                        self.parseClient.fetchTeamMembersFor(managerId: person.objectId!, isAscending1: true, isAscending2: nil, orderBy1: ObjectKeys.Person.lastName, orderBy2: nil, isDeleted: false) { (members: [PFObject]?, error: Error?) in
                            if let error = error {
                                completion(false, error)
                            } else {
                                if let members = members {
                                    self.teamMembers = members
                                    completion(true, nil)
                                    
                                    if members.count > 0 {
                                        debugPrint("Fetch members returned \(members.count) members")
                                    } else {
                                        debugPrint("Fetch members returned 0 members")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else { // In Person
            self.currentPerson = person!
            parseClient.fetchTeamMembersFor(managerId: person!.objectId!, isAscending1: true, isAscending2: nil, orderBy1: ObjectKeys.Person.lastName, orderBy2: nil, isDeleted: false) { (members: [PFObject]?, error:Error?) in
                if let error = error {
                    completion(false, error)
                } else {
                    if let members = members {
                        self.teamMembers = members
                        completion(true, nil)
                        
                        if members.count > 0 {
                            debugPrint("Fetch members returned \(members.count) members")
                        } else {
                            debugPrint("Fetch members returned 0 members")
                        }
                    }
                }
            }
        }
    }
    
    /*
    func refreshTeamMembersData() {
        fetchTeamMembersForCurrentPerson { (success: Bool, error: Error?) in
            if success {
                debugPrint("refresh data successful")
            } else {
                debugPrint("refresh data error: \(error?.localizedDescription)")
            }
        }
    }*/
    
    /*
    func fetchLatestSurveyFor(personId: String, orderBy: String, limit: Int, completion: @escaping (PFObject?, Error?) -> ()) {
        parseClient.getCurrentPerson { (manager: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("Error getting current person with error: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                if let manager = manager {
                    // TODO: check if meeting < current date?
                    
                    self.parseClient.fetchMeetingsFor(personId: personId, managerId: manager.objectId!, meetingDate: nil, isAscending: false, orderBy: orderBy, limit: limit, isDeleted: false) { (meetings: [PFObject]?, error: Error?) in
                        
                        if let error = error {
                            debugPrint("Failed in fetching meetings: \(error.localizedDescription)")
                            completion(nil, error)
                        } else {
                            debugPrint("Success in fetching meetings, \(meetings?.count)")
                            if let meetings = meetings, meetings.count > 0 {
                                let meeting = meetings[0]
                                
                                if let surveyId = meeting[ObjectKeys.Meeting.surveyId] as? String {
                                    self.parseClient.fetchSurveyFor(surveyId: surveyId, isAscending: nil, orderBy: nil) { (survey: PFObject?, error: Error?) in
                                        if let error = error {
                                            completion(nil, error)
                                        } else {
                                            completion(survey, nil)
                                        }
                                    }
                                } else {
                                    debugPrint("Could not find key surveyId in Meeting object")
                                    completion(nil, error)
                                }
                            } else {
                                let userInfo = [NSLocalizedDescriptionKey: "Fetch meeting returned 0 meeting"]
                                let error = NSError(domain: "TeamViewDataSource fetchLatestSurvey", code: 0, userInfo: userInfo)
                                completion(nil, error)
                            }
                        }
                    }
                }
            }
        }
    }*/
    
    func fetchLatestSurveyFor(personId: String, orderBy: String, limit: Int, completion: @escaping (PFObject?, Error?) -> ()) {
        // TODO: check if meeting < current date?
        
        self.parseClient.fetchMeetingsFor(personId: personId, meetingDate: nil, isAscending: false, orderBy: orderBy, limit: limit, isDeleted: false) { (meetings: [PFObject]?, error: Error?) in
            
            if let error = error {
                debugPrint("Failed in fetching meetings: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                //debugPrint("Success in fetching meetings, \(meetings?.count)")
                if let meetings = meetings, meetings.count > 0 {
                    let meeting = meetings[0]
                    
                    if let surveyId = meeting[ObjectKeys.Meeting.surveyId] as? String {
                        self.parseClient.fetchSurveyFor(surveyId: surveyId, isAscending: nil, orderBy: nil) { (survey: PFObject?, error: Error?) in
                            if let error = error {
                                completion(nil, error)
                            } else {
                                completion(survey, nil)
                            }
                        }
                    } else {
                        debugPrint("Could not find key surveyId in Meeting object")
                        completion(nil, error)
                    }
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Fetch meeting returned 0 meeting"]
                    let error = NSError(domain: "TeamViewDataSource fetchLatestSurvey", code: 0, userInfo: userInfo)
                    completion(nil, error)
                }
            }
        }
    }

    func getSelectedPersonObjectAt(indexPath: IndexPath) -> PFObject? {
        if 0 <= indexPath.row && indexPath.row < teamMembers.count {
            return teamMembers[indexPath.row]
        }
        return nil
    }

    func isPersonManager(personId: String, isDeleted: Bool, isManager: @escaping (Bool, Error?)->()) {
        parseClient.isPersonManager(personId: personId, isDeleted: isDeleted, isManager: isManager)
    }
    
    func removeSelectedPersonObjectAt(indexPath: IndexPath, completion: @escaping (Bool, Error?)->()) {
        // update Parse
        let person = teamMembers[indexPath.row]
        person[ObjectKeys.Person.deletedAt] = Date()
        
        person.saveInBackground { (success: Bool, error: Error?) in
            if success {
                debugPrint("Deleting \(person) successful")
                self.teamMembers.remove(at: indexPath.row)
                completion(true, nil)
            } else {
                debugPrint("Unable to delete \(person) with error: \(error?.localizedDescription)")
                completion(false, error)
            }
        }
    }
    
    func numberOfMembers() -> Int {
        return teamMembers.count
    }
}

extension TeamViewDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Team.teamListCell, for: indexPath) as! TeamTableViewCell
        let firstName = teamMembers[indexPath.row][ObjectKeys.Person.firstName] as? String ?? ""
        let lastName = teamMembers[indexPath.row][ObjectKeys.Person.lastName] as? String ?? ""
        let positionDesc = teamMembers[indexPath.row][ObjectKeys.Person.positionDesc] as? String ?? ""
        cell.firstNameLabel.text = firstName != lastName ? "\(firstName) \(lastName)" : firstName
        cell.positionDescLabel.text = positionDesc
        cell.emailButton.setTitle(teamMembers[indexPath.row][ObjectKeys.Person.email] as? String, for: .normal)
        cell.delegate = self
		cell.profileImageView.pffile = teamMembers[indexPath.row][ObjectKeys.Person.photo] as? PFFile

        fetchLatestSurveyFor(personId: teamMembers[indexPath.row].objectId!, orderBy: ObjectKeys.Meeting.meetingDate, limit: 1) { (survey: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("Unable to fetch survey data: \(error.localizedDescription)")
                cell.survey = nil
            } else {
                //debugPrint("survey is \(survey)")
                cell.survey = survey
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.teamViewDataSource?(self, at: indexPath)
        }
    }
}

extension TeamViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //debugPrint("teamMembers count: \(teamMembers.count)")
        return min(teamMembers.count, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseIdentifier.Team.teamCollectionCell, for: indexPath) as! TeamCollectionCell

        let firstName = teamMembers[indexPath.row][ObjectKeys.Person.firstName] as? String ?? ""
        let lastName = teamMembers[indexPath.row][ObjectKeys.Person.lastName] as? String ?? ""
        cell.nameLabel.text = firstName != lastName ? "\(firstName) \(lastName)" : firstName
		cell.profileImageView.pffile = teamMembers[indexPath.row][ObjectKeys.Person.photo] as? PFFile
        cell.profileImageView.layer.cornerRadius = 5
        cell.delegate = self
        
        fetchLatestSurveyFor(personId: teamMembers[indexPath.row].objectId!, orderBy: ObjectKeys.Meeting.meetingDate, limit: 1) {(survey: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("error: \(error.localizedDescription)")
                cell.survey = nil
            } else {
                //debugPrint("survey is \(survey)")
                cell.survey = survey
            }
        }
    
        return cell
    }
}

extension TeamViewDataSource: TeamTableViewCellDelegate, TeamCollectionCellDelegate {
    func teamTableViewCell(_ teamTableViewCell: TeamTableViewCell, survey: PFObject) {
        delegate?.teamViewDataSource?(self, surveyButtonTap: survey)
    }
    
    func teamCollectionCell(_ teamCollectionCell: TeamCollectionCell, survey: PFObject) {
        delegate?.teamViewDataSource?(self, surveyButtonTap: survey)
    }
}
