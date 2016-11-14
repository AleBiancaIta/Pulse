//
//  TeamViewDataSource.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TeamViewDataSource: NSObject {
    
    // MARK: - Properties
    
    var parseClient = ParseClient.sharedInstance()
    //var teamMembers = [Person]()
    var teamMembers = [PFObject]()
    //var meetings = [Meeting]()
    var currentPerson: PFObject?
    
    // MARK: - Shared instance
    class func sharedInstance() -> TeamViewDataSource {
        struct Singleton {
            static var sharedInstance = TeamViewDataSource()
        }
        return Singleton.sharedInstance
    }
    
    func fetchTeamMembersForCurrentPerson(completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        parseClient.getCurrentPerson { (person: PFObject?, error: Error?) in
            if let error = error {
                completion(false, error)
            } else {
                if let person = person {
                    self.currentPerson = person
                    self.parseClient.fetchTeamMembersFor(managerId: person.objectId!, completion: { (members: [PFObject]?, error: Error?) in
                        if let error = error {
                            completion(false, error)
                        } else {
                            if let members = members {
                                self.teamMembers = members
                                completion(true, nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func refreshTeamMembersData() {
        fetchTeamMembersForCurrentPerson { (success: Bool, error: Error?) in
            if success {
                debugPrint("refresh data successful")
            } else {
                debugPrint("refresh data error: \(error?.localizedDescription)")
            }
        }
    }
}

extension TeamViewDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // PLACEHOLDER
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // PLACEHOLDER
        return teamMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Team.teamListCell, for: indexPath) as! TeamTableViewCell
        cell.firstNameLabel.text = teamMembers[indexPath.row][ObjectKeys.Person.firstName] as? String
        cell.emailLabel.text = teamMembers[indexPath.row][ObjectKeys.Person.email] as? String
        return cell
    }
}

extension TeamViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        debugPrint("teamMembers count: \(teamMembers.count)")
        return teamMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseIdentifier.Team.teamCollectionCell, for: indexPath) as! TeamCollectionCell
        cell.profileImageView.image = UIImage(named: "DefaultPhoto")
        cell.nameLabel.text = teamMembers[indexPath.row][ObjectKeys.Person.firstName] as? String
        debugPrint("indexPath.row \(indexPath.row)")
        return cell
        
        
    }
    
    
}

