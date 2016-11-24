//
//  TeamListViewController.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class TeamListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    let dataSource = TeamViewDataSource.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Team Members"
        
        tableView.register(UINib(nibName: "TeamTableViewCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Team.teamListCell)
        tableView.delegate = self
        
        subscribeToNotifications()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonTap(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.dataSource = self.dataSource
        dataSource.fetchTeamMembersForCurrentPerson { (success: Bool, error: Error?) in
            if success {
                debugPrint("successfully fetching team members")
                self.tableView.reloadData()
            } else {
                debugPrint("Unable to load data with error: \(error?.localizedDescription)")
                //self.showAlert(title: "Error", message: "Unable to load data", sender: nil, handler: nil)
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
        return 120.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Person2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Person2DetailsViewController") as! Person2DetailsViewController
        viewController.personPFObject = dataSource.getSelectedPersonObjectAt(indexPath: indexPath)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
