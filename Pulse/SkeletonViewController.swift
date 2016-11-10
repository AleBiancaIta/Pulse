//
//  SkeletonViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

enum Card: Int {
    case meetings = 0, org_chart, photo_notes, pulse_graph, team, to_do
    static var count: Int { return Card.to_do.hashValue + 1}
}

class SkeletonViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
    var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBAction
    
    @IBAction func onAddCard(_ sender: UIBarButtonItem) {
        guard cards.count != Card.count else {
            alertController.message = "You already have all the cards"
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alertController, animated: true)
            return
        
        } /*else if cards.contains(.pulse_graph) {
            // Error: Already have this card
        }*/
        
        // Insert new card at the top of the table view
        cards.insert(Card(rawValue: cards.count)!, at: 0)
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource

extension SkeletonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO replace the cells with the actual view
        switch cards[indexPath.row] {
        case .meetings:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
            cell.textLabel?.text = "Meetings"
            return cell
        case .org_chart:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
            cell.textLabel?.text = "Organizational Chart"
            return cell
        case .photo_notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
            cell.textLabel?.text = "Photo Notes"
            return cell
        case .pulse_graph:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
            cell.textLabel?.text = "Pulse Graph"
            return cell
        case .team:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
            cell.textLabel?.text = "Team"
            return cell
        case .to_do:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
            cell.textLabel?.text = "To Dos"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            cards.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate

extension SkeletonViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
