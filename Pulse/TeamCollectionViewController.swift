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
    
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = TeamViewDataSource.sharedInstance()
    var person: PFObject! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Team Members"

        collectionView.register(UINib(nibName: "TeamCollectionCell", bundle: nil), forCellWithReuseIdentifier: CellReuseIdentifier.Team.teamCollectionCell)
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        subscribeToNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.dataSource = self.dataSource
        dataSource.fetchTeamMembersForCurrentPerson(person: self.person) { (success: Bool, error: Error?) in
            if success {
                debugPrint("successfully fetching team members")
                if self.dataSource.teamMembers.count == 0 {
                    self.seeAllButton.isHidden = true
                } else {
                    self.seeAllButton.isHidden = false
                }
                self.collectionView.reloadData()
            } else {
                debugPrint("Unable to load data with error: \(error?.localizedDescription)")
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
