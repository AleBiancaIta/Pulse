//
//  PersonDetailsSelectionViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/23/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

protocol PersonDetailsSelectionViewControllerDelegate: class {
    func personDetailsSelectionViewController(personDetailsSelectionViewController: PersonDetailsSelectionViewController, didAddCard card: Card)
    func personDetailsSelectionViewController(personDetailsSelectionViewController: PersonDetailsSelectionViewController, didRemoveCard card: Card)
}

class PersonDetailsSelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: PersonDetailsSelectionViewControllerDelegate?
    var selectedCards: [Card] = []
    
    var alertController: UIAlertController = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        title = "Person Cards"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton(_:)))
    }
    
    @objc fileprivate func onDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension PersonDetailsSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = Constants.personCards[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
        cell.textLabel?.text = card.name
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        
        if selectedCards.contains(card) {
            cell.accessoryType =  .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.personCards.count
    }
}

// MARK: - UITableViewDelegate

extension PersonDetailsSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row != 0 && indexPath.row != 1 else {
            alertController.message = "Sorry, info and team cards may not be manually updated"
            present(alertController, animated: true)
            return
        }
        
        let card = Constants.personCards[indexPath.row]
        if selectedCards.contains(card) {
            for (index, personCard) in selectedCards.enumerated() {
                // Double check to avoid index out of bounds
                if personCard.id == card.id && 0 <= index && selectedCards.count > index {
                    selectedCards.remove(at: index)
                }
            }
            delegate?.personDetailsSelectionViewController(personDetailsSelectionViewController: self, didRemoveCard: card)
        } else {
            selectedCards.append(card)
            delegate?.personDetailsSelectionViewController(personDetailsSelectionViewController: self, didAddCard: card)
        }
        
        tableView.reloadData()
    }
}
