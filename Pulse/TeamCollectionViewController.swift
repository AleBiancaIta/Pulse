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
        collectionView.dataSource = self.dataSource
        
        subscribeToNotifications()
        
    }

    // MARK: - Actions
    
    @IBAction func onAddButtonTap(_ sender: UIButton) {
        debugPrint("Add button tapped")
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
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TeamCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 155.0, height: 210.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // SEGUE TO EMPLOYEE DETAIL PAGE
    }
    
    
    
    
    
}
