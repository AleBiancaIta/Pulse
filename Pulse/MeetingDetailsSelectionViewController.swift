//
//  MeetingDetailsSelectionViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

protocol MeetingDetailsSelectionViewControllerDelegate: class {
    func meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: MeetingDetailsSelectionViewController, didAddCard card: Card)
    func meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: MeetingDetailsSelectionViewController, didRemoveCard card: Card)
}

class MeetingDetailsSelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MeetingDetailsSelectionViewControllerDelegate?
    var selectedCards: [Card] = []
    
    var alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        title = "Meeting Cards"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton(_:)))
    }
    
    // MARK: - IBAction
    
    @objc fileprivate func onDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension MeetingDetailsSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = Constants.meetingCards[indexPath.row]
        
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
        return Constants.meetingCards.count
    }
}

// MARK: - UITableViewDelegate

extension MeetingDetailsSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        let card = Constants.meetingCards[indexPath.row]
        
        if selectedCards.contains(card) {
            for (index, meetingCard) in selectedCards.enumerated() {
                // Double check to avoid index out of bounds
                if meetingCard.id == card.id && 0 <= index && selectedCards.count > index {
                    selectedCards.remove(at: index)
                }
            }
            delegate?.meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: self, didRemoveCard: card)
        } else {
            selectedCards.append(card)
            delegate?.meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: self, didAddCard: card)
        }
        
        tableView.reloadData()
    }
}
