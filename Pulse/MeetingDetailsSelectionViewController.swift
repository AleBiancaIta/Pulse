//
//  MeetingDetailsSelectionViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

protocol MeetingDetailsSelectionViewControllerDelegate: class {
    func meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: MeetingDetailsSelectionViewController, didDismissSelector _: Bool)
    func meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: MeetingDetailsSelectionViewController, didAddCard card: Card)
    func meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: MeetingDetailsSelectionViewController, didRemoveCard card: Card)
}

class MeetingDetailsSelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MeetingDetailsSelectionViewControllerDelegate?
    var selectedCards: [Card] = []
    
    //var alertController = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manage Modules"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 5
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        tableView.register(UINib(nibName: "CustomTextCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
    }
    
    // MARK: - IBAction
    
    @IBAction func onDismiss(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        delegate?.meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: self, didDismissSelector: true)
    }
}

// MARK: - UITableViewDataSource

extension MeetingDetailsSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = Constants.meetingCards[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! CustomTextCell
        cell.message = card.name
        cell.submessage = card.descr
        cell.imageName = card.imageName
        
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
        
        guard indexPath.row != 0 else {
            //alertController.message = "Sorry, survey card may not be manually updated"
            //present(alertController, animated: true)
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Sorry, survey card may not be manually updated")
            return
        }
        
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
            if 0 <= indexPath.row && indexPath.row < Constants.meetingCards.count {
                selectedCards.append(card)
                delegate?.meetingDetailsSelectionViewController(meetingDetailsSelectionViewController: self, didAddCard: card)
            }
        }
        
        tableView.reloadData()
    }
}
