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
    case add = 0, list, showCompleted, listCompleted
}

enum ViewTypes: String {
    case dashboard = "Dashboard View"
    case employeeDetail = "Employee Detail View"
    case meeting = "Meeting View"
}

enum TodoLimit: String {
    case topEntries = "Top Entries"
    case seeAll = "See All"
}

class TodoViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topSectionView: UIView!
    
    fileprivate let CellSections = ["Add Todo", "List Todo", "Show Completed", "List Completed"]
    fileprivate let parseClient = ParseClient.sharedInstance()
    
    var todoItems = [PFObject]()
    var todoCompletedItems = [PFObject]()
    
    var shouldShowCompleted = false
    var viewTypes: ViewTypes = .dashboard // FOR TESTING ONLY
    var todoLimit: TodoLimit = .topEntries // FOR TESTING ONLY
    var limitParameter: Int?
    
    var currentManager: PFObject?
    var currentTeamPerson: PFObject?
    //var currentMeeting: PFObject?
    var currentMeeting: Meeting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellNibs()
        configureRowHeight()
        setUpTopSectionView()
        
        // FOR TESTING ONLY
        //currentTeamPerson = makeFakePerson()
        //currentMeeting = makeFakeMeeting()
    }
    
    /*
    fileprivate func makeFakeMeeting() -> PFObject {
        let fakeMeeting = PFObject(className: "Meeting")
        fakeMeeting[ObjectKeys.Meeting.objectId] = "C47VdSyaGG"
        fakeMeeting[ObjectKeys.Meeting.personId] = "IAa9IGKU3p"
        return fakeMeeting
    }
    
    fileprivate func makeFakePerson() -> PFObject {
        let fakePerson = PFObject(className: "Person")
        fakePerson[ObjectKeys.Person.objectId] = "IAa9IGKU3p"
        return fakePerson
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        populateTodoTables()
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
    
    fileprivate func populateTodoTables() {
        parseClient.getCurrentPerson { (manager: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("Unable to retrieve current person with error: \(error.localizedDescription)")
            } else {
                if let manager = manager {
                    self.currentManager = manager
                    self.populateTodoItemsTable()
                    self.populateTodoCompletedItemsTable()
                } else {
                    debugPrint("Manager is nil")
                }
            }
        }
    }
    
    fileprivate func populateTodoItemsTable() {
        switch viewTypes {
        case .dashboard:
            if let manager = self.currentManager {
                parseClient.fetchTodoFor(managerId: manager.objectId!, personId: nil, meetingId: nil, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: false) {  (items: [PFObject]?, error: Error?) in
                    
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
            // We only want to show the todo related to the current user account
            if let manager = self.currentManager, let currentTeamPerson = self.currentTeamPerson {
                parseClient.fetchTodoFor(managerId: manager.objectId!, personId: currentTeamPerson.objectId!, meetingId: nil, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: false) { (items: [PFObject]?, error: Error?) in
                    
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
            }  else {
                debugPrint("Manager or current team member is nil, cannot fetch todoItems")
            }
        case .meeting:
            // pass in managerId, personId, meetingId
            // We only want to show the todo related to the current user account
            if let manager = self.currentManager, let currentMeeting = self.currentMeeting {
                //let personId = currentMeeting[ObjectKeys.Meeting.personId] as! String
                let personId = currentMeeting.personId
                
                parseClient.fetchTodoFor(managerId: manager.objectId!, personId: personId, meetingId: currentMeeting.objectId!, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: false) { (items: [PFObject]?, error: Error?) in
                    
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
            }  else {
                debugPrint("Manager or current meeting object is nil, cannot fetch todoItems")
            }
        }
    }

    fileprivate func populateTodoCompletedItemsTable() {
        switch viewTypes {
        case .dashboard:
            if let manager = self.currentManager {
                parseClient.fetchTodoFor(managerId: manager.objectId!, personId: nil, meetingId: nil, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: true) {  (items: [PFObject]?, error: Error?) in
                    
                    if let error = error {
                        debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
                    } else {
                        if let items = items, items.count > 0 {
                            self.todoCompletedItems = items
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
            // We only want to show the todo related to the current user account
            if let manager = self.currentManager, let currentTeamPerson = self.currentTeamPerson {
                parseClient.fetchTodoFor(managerId: manager.objectId!, personId: currentTeamPerson.objectId!, meetingId: nil, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: true) { (items: [PFObject]?, error: Error?) in
                    
                    if let error = error {
                        debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
                    } else {
                        if let items = items, items.count > 0 {
                            self.todoCompletedItems = items
                            self.tableView.reloadData()
                            debugPrint("Fetching todo items successful, reloading table")
                        } else {
                            debugPrint("TodoItems is nil or contains 0 items")
                        }
                    }
                }
            }  else {
                debugPrint("Manager or current team member is nil, cannot fetch todoItems")
            }
        case .meeting:
            // pass in managerId, personId, meetingId
            // We only want to show the todo related to the current user account
            if let manager = self.currentManager, let currentMeeting = self.currentMeeting {
                //let personId = currentMeeting[ObjectKeys.Meeting.personId] as! String
                let personId = currentMeeting.personId
                
                parseClient.fetchTodoFor(managerId: manager.objectId!, personId: personId, meetingId: currentMeeting.objectId!, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: true) { (items: [PFObject]?, error: Error?) in
                    
                    if let error = error {
                        debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
                    } else {
                        if let items = items, items.count > 0 {
                            self.todoCompletedItems = items
                            self.tableView.reloadData()
                            debugPrint("Fetching todo items successful, reloading table")
                        } else {
                            debugPrint("TodoItems is nil or contains 0 items")
                        }
                    }
                }
            }  else {
                debugPrint("Manager or current meeting object is nil, cannot fetch todoItems")
            }
        }
    }
    
    
    fileprivate func setUpTopSectionView() {
        switch todoLimit {
        case .topEntries:
            topSectionView.isHidden = false
            limitParameter = 3
        case .seeAll:
            topSectionView.isHidden = true
            limitParameter = nil
        }
    }
    
    fileprivate func openSeeAllTodoVC() {
        let storyboard = UIStoryboard.init(name: "Todo", bundle: nil)
        let seeAllTodoVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.todoVC) as! TodoViewController
        seeAllTodoVC.currentManager = self.currentManager
        seeAllTodoVC.viewTypes = self.viewTypes
        seeAllTodoVC.todoLimit = .seeAll
        seeAllTodoVC.limitParameter = nil
        self.navigationController?.pushViewController(seeAllTodoVC, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func onSeeAllButtonTap(_ sender: UIButton) {
        openSeeAllTodoVC()
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
        if shouldShowCompleted {
            return CellSections.count
        } else {
            return CellSections.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch CellTypes(rawValue: section)! {
        case .add:
            return 1
        case .list:
            return todoItems.count
        case .showCompleted:
            switch todoLimit {
            case .topEntries:
                return 0
            case .seeAll:
                return 1
            }
        case .listCompleted:
            return todoCompletedItems.count
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
            return cell
        case .showCompleted:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoShowCompletedCell, for: indexPath) as! TodoShowCompletedCell
            if shouldShowCompleted {
                cell.labelString = "HIDE COMPLETED TO-DOS"
            } else {
                cell.labelString = "SHOW COMPLETED TO-DOS"
            }
            return cell
        case .listCompleted:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoListCell, for: indexPath) as! TodoListCell
            cell.todoObject = todoCompletedItems[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch CellTypes(rawValue: indexPath.section)! {
        case .add:
            break
        case .list:
            break
        case .showCompleted:
            shouldShowCompleted = !shouldShowCompleted
            tableView.reloadData()
            
        case .listCompleted:
            break
        }
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
        if let manager = currentManager {
            todoObject[ObjectKeys.ToDo.managerId] = manager.objectId!
        }
        todoObject[ObjectKeys.ToDo.text] = todoString
        
        switch viewTypes {
        case ViewTypes.dashboard:
            debugPrint("Adding todo in dashboard")
            
        case ViewTypes.employeeDetail:
            // add personId (employeeId) to the todoObject dictionary
            if let currentTeamPerson = currentTeamPerson {
                todoObject[ObjectKeys.ToDo.personId] = currentTeamPerson.objectId!
            }
        case ViewTypes.meeting:
            // add personId and meetingId to the todoObject dictionary
            if let currentMeeting = currentMeeting {
                //let personId = currentMeeting[ObjectKeys.Meeting.personId] as! String
                let personId = currentMeeting.personId
                todoObject[ObjectKeys.ToDo.personId] = personId
                todoObject[ObjectKeys.ToDo.meetingId] = currentMeeting.objectId!
            }
        }
        return todoObject
    }
    
}
