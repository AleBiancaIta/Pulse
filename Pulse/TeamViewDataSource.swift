//
//  TeamViewDataSource.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class TeamViewDataSource: NSObject {
    
    // MARK: - Properties
    
    // MARK: - Shared instance
    class func sharedInstance() -> TeamViewDataSource {
        struct Singleton {
            static var sharedInstance = TeamViewDataSource()
        }
        return Singleton.sharedInstance
    }
}

extension TeamViewDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // PLACEHOLDER
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // PLACEHOLDER
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Team.teamListCell, for: indexPath)
        return cell
    }
}

extension TeamViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseIdentifier.Team.teamCollectionCell, for: indexPath) as! TeamCollectionCell
        
        cell.profileImageView.image = UIImage(named: "DefaultPhoto")
        cell.nameLabel.text = "Testing"
        return cell
        
        
    }
    
    
}

