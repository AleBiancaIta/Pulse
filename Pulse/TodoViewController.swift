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
    case dashboard = "Dashboard"
    case employeeDetail = "Employee Detail"
}

class TodoViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate let CellSections = ["Add Todo", "List Todo", "Show Completed"]
    var todoItems: [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellNibs()
        configureRowHeight()
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
            //return todoItems.count ?? 0
            return 1
        case .showCompleted:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch CellTypes(rawValue: indexPath.section)! {
        case .add:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoAddCell, for: indexPath) as! TodoAddCell
            return cell
        case .list:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Todo.todoListCell, for: indexPath) as! TodoListCell
            cell.nameLabel.text = "member1"
            cell.todoLabel.text = "This is a a very very very very very long todoosssss"
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
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
