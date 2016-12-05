//
//  TodoEditViewController.swift
//  Pulse
//
//  Created by Itasari on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse
import RKDropdownAlert

@objc protocol TodoEditViewControllerDelegate {
    @objc optional func todoEditViewController(_ todoEditViewController: TodoEditViewController, didUpdate success: Bool)
    @objc optional func todoEditViewController(_ todoEditViewController: TodoEditViewController, onSaveButtonTap success: Bool)
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
    //weak var delegate2: TodoEditViewControllerDelegate?

    var isTextUpdated: Bool = false
    var newTextFromEdit: String? = nil
    //var isSelectedPersonUpdated: Bool = false
    
    enum EditCellTypes: Int {
        case text = 0, person
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Follow Up Item"
        registerCellNibs()
        configureRowHeight()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButton(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewTypes == .dashboard {
            fetchTeamMembers()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /*
        if let selectedPerson = personRowSelected {
            todoItem[ObjectKeys.ToDo.personId] = teamMembers[selectedPerson].objectId!
            
            todoItem.saveInBackground { (success: Bool, error: Error?) in
                if success {
                    //debugPrint("Successfully updating todo item")
                    self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success!", message: "Successfully updated todo item")
                    self.delegate?.todoEditViewController?(self, didUpdate: true)
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to update todo with error: \(error?.localizedDescription)")
                    //debugPrint("Failed to update todo with error: \(error?.localizedDescription)")
                }
            }
        }
        
        // TODO: not the best solution as it's actually showing up twice
        if isTextUpdated {
            self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success", message: "Successfully updated todo item")
            isTextUpdated = false
        }*/
    }
    
    func onSaveButton(_ sender: UIBarButtonItem) {
        debugPrint("Save button tapped")
        delegate?.todoEditViewController?(self, onSaveButtonTap: true)
        
        if isTextUpdated || (personRowSelected != nil) {
            if let newText = newTextFromEdit {
                debugPrint("in todo edit view controller, \(newText)")
                todoItem[ObjectKeys.ToDo.text] = newText
            } else {
                debugPrint("newTextFromEdit is nil")
            }
            
            if let selectedPerson = personRowSelected {
                debugPrint("in todo edit view controller, selectedPerson: \(selectedPerson)")
                todoItem[ObjectKeys.ToDo.personId] = teamMembers[selectedPerson].objectId!
            }
            
            todoItem.saveInBackground { (success: Bool, error: Error?) in
                if success {
                    //debugPrint("Successfully updating todo item")
                    //self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success!", message: "Successfully updated todo item")
                    self.ABIShowDropDownAlertWithDelegate(type: AlertTypes.success, title: "Success!", message: "Successfully updated todo item", delegate: self)
                    self.delegate?.todoEditViewController?(self, didUpdate: true)
                } else {
                    if let error = error {
                        self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to update todo with error: \(error.localizedDescription)")
                    } else {
                        self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to update todo with error")
                    }
                    //debugPrint("Failed to update todo with error: \(error?.localizedDescription)")
                }
            }
        } else {
            self.ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "No new update. Nothing to saved")
        }
        
        /*
        // TODO: not the best solution as it's actually showing up twice
        if isTextUpdated {
            self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success", message: "Successfully updated todo item")
            isTextUpdated = false
        }*/
        
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
        case .dashboard:
            // If meetingId is populated, do not show person drop down
            if let _ = todoItem[ObjectKeys.ToDo.meetingId] as? String {
                return cellSections.count - 1
            } else {
                return cellSections.count
            }
        default: // coming from Person or Meeting, can only edit the text
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
            self.delegate = cell
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
    
    func todoEditTextCell(_ todoEditTextCell: TodoEditTextCell, didSave: Bool) {
        if didSave {
            isTextUpdated = true
            //self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success!", message: "Successfully updated todo item")
        }
    }
    
    func todoEditTextCell(_ todoEditTextCell: TodoEditTextCell, didEditOnSave newText: String) {
        isTextUpdated = true
        newTextFromEdit = newText
        //tableView.reloadData()
    }
}

// MARK: - RKDropDownAlertDelegate

extension TodoEditViewController: RKDropdownAlertDelegate {
    
    func dropdownAlertWasDismissed() -> Bool {
        navigationController?.popViewController(animated: true)
        return true
    }
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
}
