//
//  TodoViewController.swift
//  Pulse
//
//  Created by Itasari on 11/19/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

enum CellTypes: Int {
    case add = 0, list, showCompleted
}

enum ViewTypes: String {
    case dashboard = "Dashboard View"
    case employeeDetail = "Employee Detail View"
    case meeting = "Meeting View"
}

class TodoViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let CellSections = ["Add Todo", "List Todo", "Show Completed"]
    fileprivate let parseClient = ParseClient.sharedInstance()
    
    var todoItems = [PFObject]()
    var viewTypes: ViewTypes = .dashboard // FOR TESTING ONLY
    var currentPerson: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellNibs()
        configureRowHeight()
        getCurrentPerson()
    }
    
    func heightForView() -> CGFloat {
        return 240; // TODO fix this to calculate height properly
    }

    // MARK: - Helpers
    
    fileprivate func configureRowHeight() {
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    fileprivate func registerCellNibs() {
        tableView.register(UINib(nibName: "TodoAddCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Todo.todoAddCell)
        tableView.register(UINib(nibName: "TodoListCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Todo.todoListCell)
        tableView.register(UINib(nibName: "TodoShowCompletedCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Todo.todoShowCompletedCell)
    }
    
    fileprivate func getCurrentPerson() {
        parseClient.getCurrentPerson { (manager: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("Unable to retrieve current person with error: \(error.localizedDescription)")
            } else {
                if let manager = manager {
                    self.currentPerson = manager
                    self.populateTodoItemsTable()
                } else {
                    debugPrint("Manager is nil")
                }
            }
        }
    }
    
    fileprivate func populateTodoItemsTable() {
        switch viewTypes {
        case .dashboard:
            if let manager = self.currentPerson {
                parseClient.fetchTodoFor(managerId: manager.objectId!, personId: nil, meetingId: nil, isDeleted: false) {  (items: [PFObject]?, error: Error?) in
                    if let error = error {
                        debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
                    } else {
                        if let items = items, items.count > 0 {
                            self.todoItems = items
                            self.tableView.reloadData()
                            debugPrint("Fetching todo items successful, reloading table")
                        } else {
                            debugPrint("TodoItems is nil or contains 0 items")
                        }
                    }
                }
            } else {
                debugPrint("Manager is nil, cannot fetch todoItems")
            }
        case .employeeDetail:
            // pass in managerId, personId
            break
        case .meeting:
            // pass in managerId, personId, meetingId
            break
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

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return CellSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch CellTypes(rawValue: section)! {
        case .add:
            return 1
        case .list:
            return todoItems.count
        case .showCompleted:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch CellTypes(rawValue: indexPath.section)! {
        case .add:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoAddCell, for: indexPath) as! TodoAddCell
            cell.delegate = self
            return cell
        case .list:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoListCell, for: indexPath) as! TodoListCell
            cell.todoObject = todoItems[indexPath.row]
            //cell.nameLabel.text = "member1"
            //cell.todoLabel.text = "This is a a very very very very very long todoosssss"
            return cell
        case .showCompleted:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoShowCompletedCell, for: indexPath) as! TodoShowCompletedCell
            cell.labelString = "SHOW COMPLETED TO-DOS"
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

extension TodoViewController: TodoAddCellDelegate {
    func todoAddCell(_ todoAddCell: TodoAddCell, todoString: String) {
        debugPrint("textfield did return: \(todoString)")
        let newTodo = createTodoObject(todoString: todoString)
        
        if todoItems.count == 0 {
            todoItems.append(newTodo)
        } else {
            todoItems.insert(newTodo, at: 0)
        }
        tableView.reloadData()
        
        //tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        
        //todoItems.insert(newTodo, at: 0)
        //tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
//        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = false
//        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.alpha = 0.5
        
        
        parseClient.saveTodoToParse(todo: newTodo) { (success: Bool, error: Error?) in
            if success {
                debugPrint("Successfully adding new follow-up item")
                //self.tableView.reloadData()
            } else {
                //remove the new todo added - need to test this
                self.ABIShowAlert(title: "Error", message: "Adding new item: error \(error?.localizedDescription). Please try again later", sender: nil, handler: { (alertAction: UIAlertAction) in
                    self.todoItems.remove(at: 0)
                    self.tableView.reloadData()
                })
            }
        }


        // save to Parse
        // reload table
        // maybe explore batching request when have time?
    }
    
    // MARK: - Helpers
    // TODO: move the PFObject and Parse logic to Todo wrapper class?
    fileprivate func createTodoObject(todoString: String) -> PFObject {
        let todoObject = PFObject(className: "ToDo")
        if let manager = currentPerson {
            todoObject[ObjectKeys.ToDo.managerId] = manager.objectId!
        }
        todoObject[ObjectKeys.ToDo.text] = todoString
        
        /*
        switch viewTypes {
        case ViewTypes.dashboard:
            break
        case ViewTypes.employeeDetail:
            // add personId (employeeId) to the todoObject dictionary
            break
        case ViewTypes.meeting:
            // add personId and meetingId to the todoObject dictionary
            break
        }*/
        
        return todoObject
    }
    
}
