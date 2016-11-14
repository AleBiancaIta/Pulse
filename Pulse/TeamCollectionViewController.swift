//
//  TeamCollectionViewController.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class TeamCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = TeamViewDataSource.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "TeamCollectionCell", bundle: nil), forCellWithReuseIdentifier: CellReuseIdentifier.Team.teamCollectionCell)
        collectionView.delegate = self
        
        
        subscribeToNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.dataSource = self.dataSource
        
        dataSource.fetchTeamMembersForCurrentPerson { (success: Bool, error: Error?) in
            if success {
                debugPrint("successfully fetching team members")
                self.collectionView.reloadData()
            } else {
                debugPrint("Unable to load data with error: \(error?.localizedDescription)")
                //self.showAlert(title: "Error", message: "Unable to load data", sender: nil, handler: nil)
            }
        }
    }

    // MARK: - Actions
    
    @IBAction func onAddButtonTap(_ sender: UIButton) {
		showPersonViewController(person: nil)
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
    
    func heightForView() -> CGFloat {
        return CGFloat(44 * 3) // TODO
    }
}

extension TeamCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 155.0, height: 300) //height: 210.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Person", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PersonDetailsViewController")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    
    
}
