//
//  TodoEditViewController.swift
//  Pulse
//
//  Created by Itasari on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

@objc protocol TodoEditViewControllerDelegate {
    @objc optional func todoEditViewController(_ todoEditViewController: TodoEditViewController, didUpdate success: Bool)
}

class TodoEditViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let cellSections = ["Edit Text", "Edit Person"]
    fileprivate let parseClient = ParseClient.sharedInstance()
    fileprivate var isPersonExpanded = false
    fileprivate var personRowSelected: Int? = nil
    
    var viewTypes: ViewTypes = .dashboard
    var todoItem: PFObject!
    var teamMembers = [PFObject]() // only applies to dashboard view type
    weak var delegate: TodoEditViewControllerDelegate?

    enum EditCellTypes: Int {
        case text = 0, person
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Item"
        registerCellNibs()
        configureRowHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewTypes == .dashboard {
            fetchTeamMembers()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selectedPerson = personRowSelected {
            todoItem[ObjectKeys.ToDo.personId] = teamMembers[selectedPerson].objectId!
            
            todoItem.saveInBackground { (success: Bool, error: Error?) in
                if success {
                    debugPrint("Successfully updating todo item")
                    self.delegate?.todoEditViewController?(self, didUpdate: true)
                } else {
                    debugPrint("Failed to update todo with error: \(error?.localizedDescription)")
                }
            }
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
            
            // Compound sort not working for parse?
            parseClient.fetchTeamMembersFor(managerId: managerId, isAscending1: true, isAscending2: nil, orderBy1: ObjectKeys.Person.lastName, orderBy2: nil, isDeleted: false) { (teams: [PFObject]?, error: Error?) in
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
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TodoEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch viewTypes {
        case .dashboard: // TODO - check if meetingId is populated
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
            if isPersonExpanded {
                return teamMembers.count + 1
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch EditCellTypes(rawValue: indexPath.section)! {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoEditTextCell, for: indexPath) as! TodoEditTextCell
            cell.todoItem = todoItem
            cell.delegate = self
            return cell
        case .person:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoEditPersonCell, for: indexPath) as! TodoEditPersonCell
                cell.firstRow = true
                cell.isUserInteractionEnabled = isPersonExpanded ? false : true
                
                if personRowSelected == nil {
                    if let personId = todoItem[ObjectKeys.ToDo.personId] as? String {
                        cell.personId = personId
                    }
                }
                
                if let selectedPerson = personRowSelected {
                    cell.selectedPerson = teamMembers[selectedPerson]
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoEditPersonCell, for: indexPath) as! TodoEditPersonCell
                cell.firstRow = false
                cell.isUserInteractionEnabled = true
                cell.person = teamMembers[indexPath.row - 1]
                
                if let selectedRow = personRowSelected, selectedRow == (indexPath.row - 1) {
                    cell.highlightBackground = true
                } else {
                    cell.highlightBackground = false
                }
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            if isPersonExpanded { // need to collapse
                personRowSelected = indexPath.row - 1
                isPersonExpanded = !isPersonExpanded
            } else { // need to expand
                isPersonExpanded = !isPersonExpanded
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension TodoEditViewController: TodoEditTextCellDelegate {
    func todoEditTextCell(_ todoEditTextCell: TodoEditTextCell, didEdit: Bool) {
        if didEdit {
            tableView.reloadData()
        }
    }
}
