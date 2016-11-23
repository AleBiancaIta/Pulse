//
//  TodoEditViewController.swift
//  Pulse
//
//  Created by Itasari on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TodoEditViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let cellSections = ["Edit Text", "Edit Person"]
    fileprivate let parseClient = ParseClient.sharedInstance()
    
    var viewTypes: ViewTypes = .dashboard
    var todoItem: PFObject!
    var teamMembers = [PFObject]() // only applies to dashboard view type

    enum EditCellTypes: Int {
        case text = 0, person
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellNibs()
        configureRowHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewTypes == .dashboard {
            fetchTeamMembers()
        }
    }
    
    // MARK: - Helpers

    fileprivate func configureRowHeight() {
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    fileprivate func registerCellNibs() {
        tableView.register(UINib(nibName: "TodoEditTextCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Todo.todoEditTextCell)
        tableView.register(UINib(nibName: "TodoEditPersonCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Todo.todoEditPersonCell)
    }
    
    fileprivate func fetchTeamMembers() {
        if let todoItem = todoItem {
            let managerId = todoItem[ObjectKeys.ToDo.managerId] as! String
            
            parseClient.fetchTeamMembersFor(managerId: managerId) { (teams: [PFObject]?, error: Error?) in
                if let error = error {
                    debugPrint("Failed to fetch team members with error: \(error.localizedDescription)")
                } else {
                    if let teams = teams, teams.count > 0  {
                        self.teamMembers = teams
                        self.tableView.reloadData()
                    } else {
                        debugPrint("Fetching team members returned 0 result")
                    }
                }
            }
        }
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

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TodoEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch viewTypes {
        case .dashboard:
            return cellSections.count
        default:
            return cellSections.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch EditCellTypes(rawValue: section)! {
        case .text:
            return 1
        case .person:
            return teamMembers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch EditCellTypes(rawValue: indexPath.section)! {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoEditTextCell, for: indexPath) as! TodoEditTextCell
            cell.todoItem = todoItem
            return cell
        case .person:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoEditPersonCell, for: indexPath) as! TodoEditPersonCell
            cell.person = teamMembers[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
