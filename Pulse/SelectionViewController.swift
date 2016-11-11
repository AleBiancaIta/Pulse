//
//  SelectionViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

protocol SelectionViewControllerDelegate: class {
    func selectionViewController(selectionViewController: SelectionViewController, didAddCard card: Card)
    func selectionViewController(selectionViewController: SelectionViewController, didRemoveCard card: Card)
}

class SelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SelectionViewControllerDelegate?
    
    let alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
    
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

extension SelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = Constants.cards[indexPath.row]
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
        cell.textLabel?.text = card.name
        
        if SkeletonViewController.cards.contains(card) {
            cell.accessoryType =  .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.cards.count
    }
}

// MARK: - UITableViewDelegate

extension SelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        let card = Constants.cards[indexPath.row]
        
        if SkeletonViewController.cards.contains(card) {
            delegate?.selectionViewController(selectionViewController: self, didRemoveCard: card)
        } else {
            delegate?.selectionViewController(selectionViewController: self, didAddCard: card)
        }
        
        tableView.reloadData()
    }
    
}
