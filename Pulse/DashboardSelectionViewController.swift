//
//  DashboardSelectionViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

protocol DashboardSelectionViewControllerDelegate: class {
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didAddCard card: Card)
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didRemoveCard card: Card)
}

class DashboardSelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: DashboardSelectionViewControllerDelegate?
    var selectedCards: [Card] = []
    
    var alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - IBAction
    
    @IBAction func onDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension DashboardSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = Constants.dashboardCards[indexPath.row]
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
        cell.textLabel?.text = card.name
        
        if selectedCards.contains(card) {
            cell.accessoryType =  .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.dashboardCards.count
    }
}

// MARK: - UITableViewDelegate

extension DashboardSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        let card = Constants.dashboardCards[indexPath.row]
        
        if selectedCards.contains(card) {
            for (index, dashboardCard) in selectedCards.enumerated() {
                if dashboardCard.id == card.id {
                    selectedCards.remove(at: index)
                }
            }
            delegate?.dashboardSelectionViewController(dashboardSelectionViewController: self, didRemoveCard: card)
        } else {
            selectedCards.append(card)
            delegate?.dashboardSelectionViewController(dashboardSelectionViewController: self, didAddCard: card)
        }
        
        tableView.reloadData()
    }
}
