//
//  TodoViewController.swift
//  Pulse
//
//  Created by Itasari on 11/19/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse
import RKDropdownAlert

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
    
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topSectionView: UIView!
    
    @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    
    fileprivate let cellSections = ["Add Todo", "List Todo", "Show Completed", "List Completed"]
    fileprivate let parseClient = ParseClient.sharedInstance()
    
    var todoItems = [PFObject]()
    var todoCompletedItems = [PFObject]()
    var deletedItemIndexPath: IndexPath? = nil
    
    var shouldShowCompleted = false
    var viewTypes: ViewTypes = .dashboard // FOR TESTING ONLY
    var todoLimit: TodoLimit = .topEntries // FOR TESTING ONLY
    var limitParameter: Int?
    
    var currentManager: PFObject?
    var currentTeamPerson: PFObject?
    //var currentMeeting: PFObject?
    var currentMeeting: Meeting?
    var currentMeetingObject: PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Follow Up Items"
        
        tableViewTrailingConstraint.constant = todoLimit == .topEntries ? 16 : 0
        //stackViewTopConstraint.constant = todoLimit == .topEntries ? 0 : 8
        stackViewLeadingConstraint.constant = todoLimit == .topEntries ? 0 : 8
        stackViewBottomConstraint.constant = todoLimit == .topEntries ? 0 : 8
        stackViewTrailingConstraint.constant = todoLimit == .topEntries ? 0 : 8
        
        UIExtensions.gradientBackgroundFor(view: view)
        tableView.layer.cornerRadius = 5
        
        registerCellNibs()
        configureRowHeight()
        setUpTopSectionView()
        //getCurrentManager()
        //getCurrentMeetingObject()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        populateTodoTables()
    }
    
    func heightForView() -> CGFloat {
        return 296;
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
    
    fileprivate func getCurrentManager(completion: @escaping (_ success: Bool, _ error: Error?)->()) {
        parseClient.getCurrentPerson { (manager: PFObject?, error: Error?) in
            if let error = error {
                //debugPrint("Unable to retrieve current person with error: \(error.localizedDescription)")
                completion(false, error)
            } else {
                if let manager = manager {
                    self.currentManager = manager
                    completion(true, nil)
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Manager is nil"]
                    let tempError = NSError(domain: "TodoVC getCurrentManager", code: 0, userInfo: userInfo) as Error
                    completion(false, tempError)
                }
            }
        }
    }
    
    fileprivate func getCurrentMeetingObject(completion: @escaping (_ success: Bool, _ error: Error?)->()) {
        if let meeting = currentMeeting, let manager = currentManager {
            parseClient.fetchMeetingsFor(personId: meeting.personId, managerId: manager.objectId!, meetingDate: meeting.meetingDate, isAscending: nil, orderBy: nil, limit: nil, isDeleted: false) { (meetings: [PFObject]?, error: Error?) in
                if let error = error {
                    debugPrint("Failed to retrieve meeting object, error: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    if let meetings = meetings, meetings.count > 0 {
                        self.currentMeetingObject = meetings[0]
                        completion(true, nil)
                    } else {
                        let userInfo = [NSLocalizedDescriptionKey: "get current meeting object returned nil"]
                        let tempError = NSError(domain: "TodoVC getCurrentMeetingObject", code: 0, userInfo: userInfo) as Error
                        completion(false, tempError)
                    }
                }
            }
        } else {
            let userInfo = [NSLocalizedDescriptionKey: "in getCurrentMeetingObject, either currentMeeting or currentManager is nil"]
            let tempError = NSError(domain: "TodoVC getCurrentMeetingObject", code: 0, userInfo: userInfo) as Error
            completion(false, tempError)
        }
    }
    
    fileprivate func populateTodoTables() {
        switch viewTypes {
        case .dashboard, .employeeDetail: // assume getting a currentTeamPerson as PFObject, if not, need to adjust
            getCurrentManager { (success: Bool, error: Error?) in
                if success {
                    self.populateTodoItemsTable()
                    self.populateTodoCompletedItemsTable()
                } else {
                    debugPrint("Couldn't get current manager with error: \(error?.localizedDescription)")
                }
            }
        case .meeting:
            getCurrentManager { (success: Bool, error: Error?) in
                if success {
                    self.getCurrentMeetingObject { (succes: Bool, error: Error?) in
                        if success {
                            self.populateTodoItemsTable()
                            self.populateTodoCompletedItemsTable()
                        } else {
                            debugPrint("Couldn't get current meeting object with error: \(error?.localizedDescription)")
                        }
                    }
                } else {
                    debugPrint("Couldn't get current manager with error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    fileprivate func populateTodoItemsTable() {
        switch viewTypes {
        case .dashboard:
            fetchTodoDashboard(isCompleted: false) { (items: [PFObject]?, error: Error?) in
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error in fetching todo items, error: \(error.localizedDescription)")
                    //debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
                } else {
                    if let items = items, items.count > 0 {
                        self.todoItems = items
                        self.tableView.reloadData()
                        debugPrint("Fetching todo items successful, reloading table")
                        self.seeAllButton.isHidden = false
                    } else {
                        debugPrint("TodoItems is nil or contains 0 items")
                        self.seeAllButton.isHidden = true
                    }
                }
            }
        case .employeeDetail:
            fetchTodoEmployeeDetail(isCompleted: false) { (items: [PFObject]?, error: Error?) in
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error in fetching todo items, error: \(error.localizedDescription)")
                    //debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
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
        case .meeting:
            fetchTodoMeeting(isCompleted: false) { (items: [PFObject]?, error: Error?) in
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error in fetching todo items, error: \(error.localizedDescription)")
                    //debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
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
        }
    }
    
    fileprivate func populateTodoCompletedItemsTable() {
        switch viewTypes {
        case .dashboard:
            fetchTodoDashboard(isCompleted: true) { (items: [PFObject]?, error: Error?) in
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error in fetching todo items, error: \(error.localizedDescription)")
                    //debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
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
        case .employeeDetail:
            fetchTodoEmployeeDetail(isCompleted: true) { (items: [PFObject]?, error: Error?) in
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error in fetching todo items, error: \(error.localizedDescription)")
                    //debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
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
        case .meeting:
            fetchTodoMeeting(isCompleted: true) { (items: [PFObject]?, error: Error?) in
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error in fetching todo items, error: \(error.localizedDescription)")
                    //debugPrint("Error in fetching todo items, error: \(error.localizedDescription)")
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
        }
    }
    
    fileprivate func fetchTodoDashboard(isCompleted: Bool, completion: @escaping ([PFObject]?, Error?)->()) {
        if let manager = self.currentManager {
            parseClient.fetchTodoFor(managerId: manager.objectId!, personId: nil, meetingId: nil, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: isCompleted, completion: completion)
        } else {
            debugPrint("Manager is nil, cannot fetch todoItems")
        }
    }
    
    fileprivate func fetchTodoEmployeeDetail(isCompleted: Bool, completion: @escaping ([PFObject]?, Error?)->()) {
        // pass in managerId, personId
        // We only want to show the todo related to the current user account
        if let manager = self.currentManager, let currentTeamPerson = self.currentTeamPerson {
            parseClient.fetchTodoFor(managerId: manager.objectId!, personId: currentTeamPerson.objectId!, meetingId: nil, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: isCompleted, completion: completion)
        }  else {
            debugPrint("Manager or current team member is nil, cannot fetch todoItems")
        }
    }
    
    fileprivate func fetchTodoMeeting(isCompleted: Bool, completion: @escaping ([PFObject]?, Error?)->()) {
        // pass in managerId, personId (from meeting), meetingId
        // We only want to show the todo related to the current user account
        if let manager = self.currentManager, let meeting = self.currentMeetingObject {
            let personId = meeting[ObjectKeys.Meeting.personId] as! String
            let meetingId = meeting.objectId!
            let managerId = manager.objectId!
            
            parseClient.fetchTodoFor(managerId: managerId, personId: personId, meetingId: meetingId, limit: limitParameter, isAscending: true, orderBy: ObjectKeys.ToDo.updatedAt, isDeleted: false, isCompleted: isCompleted, completion: completion)
        }  else {
            debugPrint("Manager or meeting object is nil, cannot fetch todoItems")
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
        
        switch viewTypes {
        case .dashboard:
            break
        case .employeeDetail:
            if let teamPerson = self.currentTeamPerson {
                seeAllTodoVC.currentTeamPerson = teamPerson
            }
        case .meeting:
            if let meeting = self.currentMeeting {
                seeAllTodoVC.currentMeeting = meeting
            }
        }
        self.navigationController?.pushViewController(seeAllTodoVC, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func onSeeAllButtonTap(_ sender: UIButton) {
        openSeeAllTodoVC()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowCompleted {
            return cellSections.count
        } else {
            return cellSections.count - 1
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
            let todoObject = todoItems[indexPath.row]
            cell.todoObject = todoObject
            
            if let _ = todoObject[ObjectKeys.ToDo.meetingId] as? String {
                cell.hasMeeting = true
            } else {
                cell.hasMeeting = false
            }
            
            if let _ = todoObject[ObjectKeys.ToDo.personId] as? String {
                cell.hasPerson = true
            } else {
                cell.hasPerson = false
            }
            
            cell.delegate = self
            return cell
        case .showCompleted:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoShowCompletedCell, for: indexPath) as! TodoShowCompletedCell
            if shouldShowCompleted {
                cell.labelString = "Hide Completed Items"
            } else {
                cell.labelString = "Show Completed Items"
            }
            return cell
        case .listCompleted:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoListCell, for: indexPath) as! TodoListCell
            let todoObject = todoCompletedItems[indexPath.row]
            cell.todoObject = todoObject

            if let _ = todoObject[ObjectKeys.ToDo.meetingId] as? String {
                cell.hasMeeting = true
            } else {
                cell.hasMeeting = false
            }
            
            if let _ = todoObject[ObjectKeys.ToDo.personId] as? String {
                cell.hasPerson = true
            } else {
                cell.hasPerson = false
            }
            
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch CellTypes(rawValue: indexPath.section)! {
        case .add:
            break
        case .list:
            let storyboard = UIStoryboard(name: "Todo", bundle: nil)
            let todoEditVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.todoEditVC) as! TodoEditViewController
            todoEditVC.viewTypes = self.viewTypes
            todoEditVC.todoItem = todoItems[indexPath.row]
            todoEditVC.delegate = self
            self.navigationController?.pushViewController(todoEditVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch CellTypes(rawValue: indexPath.section)! {
        case .list:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch CellTypes(rawValue: indexPath.section)! {
        case .list:
            if editingStyle == .delete {
                deletedItemIndexPath = indexPath
                let todoItemToDelete = todoItems[indexPath.row]
                confirmDelete(todoItem: todoItemToDelete)
            }
        default:
            // do nothing
            break
        }
    }
    
    // MARK: - Helpers
    fileprivate func confirmDelete(todoItem: PFObject) {
        ABIShowAlertWithActions(title: "Alert", message: "Are you sure you want to delete this item?", actionTitle1: "Confirm", actionTitle2: "Cancel", sender: nil, handler1: { (alertAction:UIAlertAction) in
            if alertAction.title == "Confirm" {
                self.handleDeletingItem()
            }
        }, handler2: { (alertAction: UIAlertAction) in
            if alertAction.title == "Cancel" {
                self.cancelDeletingItem()
            }
        })
    }
    
    fileprivate func handleDeletingItem() {
        if let indexPath = deletedItemIndexPath {
            tableView.beginUpdates()
            let deletedTodo = todoItems.remove(at: indexPath.row)
            deletedTodo[ObjectKeys.ToDo.deletedAt] = Date()
            tableView.deleteRows(at: [indexPath], with: .fade)
            deletedItemIndexPath = nil
            tableView.endUpdates()
            
            // Update Parse
            deletedTodo.saveInBackground(block: { (success: Bool, error: Error?) in
                if success {
                    debugPrint("Successfully 'deleting' todo item")
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to 'delete' todo item with error: \(error?.localizedDescription)")
                    //debugPrint("Failed to 'delete' todo item with error: \(error?.localizedDescription)")
                    
                    // TODO: reset deleted item or retry later?
                }
            })
        }
    }
    
    fileprivate func cancelDeletingItem() {
        // reset deletedItemIndexPath
        tableView.reloadRows(at: [deletedItemIndexPath!], with: .none)
        deletedItemIndexPath = nil
    }
}

// MARK: - TodoAddCellDelegate

extension TodoViewController: TodoAddCellDelegate {
    func todoAddCell(_ todoAddCell: TodoAddCell, todoString: String) {
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
                self.ABIShowDropDownAlertWithDelegate(type: AlertTypes.failure, title: "Error!", message: "Adding new item: error \(error?.localizedDescription). Please try again later", delegate: self)
                /*
                self.ABIShowAlert(title: "Error", message: "Adding new item: error \(error?.localizedDescription). Please try again later", sender: nil, handler: { (alertAction: UIAlertAction) in
                    self.todoItems.remove(at: 0)
                    self.tableView.reloadData()
                })*/
            }
        }

        // TODO: explore batching request when have time?
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
            if let meeting = currentMeetingObject {
                let personId = meeting[ObjectKeys.Meeting.personId] as! String
                todoObject[ObjectKeys.ToDo.personId] = personId
                todoObject[ObjectKeys.ToDo.meetingId] = meeting.objectId!
            }
        }
        return todoObject
    }
}

// MARK: - TodoListCellDelegate

extension TodoViewController: TodoListCellDelegate {
    func todoListCell(_ todoListCell: TodoListCell, isCompleted: Bool) {
        
        if isCompleted {
            if let indexPath = tableView.indexPath(for: todoListCell) {
                let todo = todoCompletedItems.remove(at: indexPath.row)
                todo.remove(forKey: ObjectKeys.ToDo.completedAt)
                todoItems.append(todo)
                tableView.reloadData()
                
                todo.saveInBackground(block: { (success: Bool, error: Error?) in
                    if success {
                        debugPrint("Successfully uncompleting task")
                    } else {
                        self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to uncomplete task, error: \(error?.localizedDescription)")
                        //debugPrint("Failed to uncomplete task, error: \(error?.localizedDescription)")
                        
                        // TODO: Retry or reset the changes?
                    }
                })
            }
        } else {
            if let indexPath = tableView.indexPath(for: todoListCell) {
                let todo = todoItems.remove(at: indexPath.row)
                todo[ObjectKeys.ToDo.completedAt] = Date()
                todoCompletedItems.insert(todo, at: 0)
                tableView.reloadData()
                
                todo.saveInBackground(block: { (success: Bool, error: Error?) in
                    if success {
                        debugPrint("Successfully updated completedAt for todo item")
                    } else {
                        self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to update completedAt for todo item, error: \(error?.localizedDescription)")
                        //debugPrint("Failed to update completedAt for todo item, error: \(error?.localizedDescription)")
                        
                        // TODO: Retry or reset the changes?
                    }
                })
            }
        }
    }
}

// MARK: - TodoEditViewControllerDelegate

extension TodoViewController: TodoEditViewControllerDelegate {
    func todoEditViewController(_ todoEditViewController: TodoEditViewController, didUpdate success: Bool) {
        if success {
            self.populateTodoTables()
            self.tableView.reloadData()
        }
    }
}

// MARK: - RKDropDownAlertDelegate

extension TodoViewController: RKDropdownAlertDelegate {
    
    func dropdownAlertWasDismissed() -> Bool {
        self.todoItems.remove(at: 0)
        self.tableView.reloadData()
        return true
    }
    
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return true
    }
}

