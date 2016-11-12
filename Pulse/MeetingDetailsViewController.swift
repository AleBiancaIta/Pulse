//
//  MeetingDetailsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class MeetingDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    static var cards: [Card] = [] // TODO put in data controller
    
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Meeting"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButton(_:)))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "CardCellNib", bundle: nil), forCellReuseIdentifier: "CardCell")
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "OK", style: .cancel))
    }
    
    // MARK: - Private Methods
    
    func onAddButton(_ sender: UIBarButtonItem) {
        guard MeetingDetailsViewController.cards.count != Constants.dashboardCards.count else {
            alertController?.message = "You already have all the cards"
            present(alertController!, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let selectionNavigationController = storyboard.instantiateViewController(withIdentifier: "SelectionNavigationController") as! UINavigationController
        
        /*if let selectionViewController = selectionNavigationController.topViewController as? SelectionViewController {
            selectionViewController.delegate = self
            selectionViewController.selectionType = "meeting"
        }*/
        
        present(selectionNavigationController, animated: true, completion: nil)
    }
    
    /*func heightForView() -> CGFloat {
        return 100
    }*/
    
}

// MARK: - SelectionViewControllerDelegate

/*extension MeetingDetailsViewController: SelectionViewControllerDelegate {
    
    func selectionViewController(selectionViewController: SelectionViewController, didAddDashboardCard card: Card) {
        // Do nothing
    }
    
    func selectionViewController(selectionViewController: SelectionViewController, didRemoveDashboardCard card: Card) {
        // Do nothing
    }
    
    func selectionViewController(selectionViewController: SelectionViewController, didAddMeetingCard card: Card) {
        // Insert new card at the top of the table view
        MeetingDetailsViewController.cards.insert(card, at: 0)
        tableView.reloadData()
    }
    func selectionViewController(selectionViewController: SelectionViewController, didRemoveMeetingCard card: Card) {
        // Remove card from table view
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id {
                MeetingDetailsViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}
*/
// MARK: - UITableViewDataSource

extension MeetingDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MeetingDetailsViewController.cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // No cards
        if MeetingDetailsViewController.cards.count == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell
            if nil == cell {
                cell = UITableViewCell(style: .default, reuseIdentifier: "MessageCell") as? MessageCell
            }
            cell?.message = "Tap the + button to add cards"
            cell?.isUserInteractionEnabled = false
            return cell!
            
            // Last section
        } else if indexPath.section == numberOfSections(in: tableView) - 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell
            if nil == cell {
                cell = UITableViewCell(style: .default, reuseIdentifier: "MessageCell") as? MessageCell
            }
            cell?.message = "Tap the + button to add cards"
            cell?.isUserInteractionEnabled = false
            return cell!
        
            // TODO replace the cells with the actual view
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as? CardCell
            if nil == cell {
                cell = (UITableViewCell(style: .default, reuseIdentifier: "CardCell") as? CardCell)!
            }
            cell?.delegate = self
            cell?.card = MeetingDetailsViewController.cards[indexPath.section]
            return cell!
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MeetingDetailsViewController.cards.count + 2
    }
}

extension MeetingDetailsViewController: UITableViewDelegate {
}

// MARK: - CardCellDelegate

extension MeetingDetailsViewController: CardCellDelegate {
    func cardCell(cardCell: CardCell, didMoveUp card: Card) {
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id {
                
                // First card
                guard index != 0 else {
                    alertController?.message = "This card cannot move up further"
                    present(alertController!, animated: true)
                    return
                }
                
                // Swap with card before
                let cardBefore = MeetingDetailsViewController.cards[index-1]
                MeetingDetailsViewController.cards[index-1] = card
                MeetingDetailsViewController.cards[index] = cardBefore
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didMoveDown card: Card) {
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id { // TODO find better way to do this
                
                // Last card
                guard index < MeetingDetailsViewController.cards.count - 1 else {
                    alertController?.message = "This card cannot move down further"
                    present(alertController!, animated: true)
                    return
                }
                
                // Swap with card after
                let cardAfter = MeetingDetailsViewController.cards[index+1]
                MeetingDetailsViewController.cards[index+1] = card
                MeetingDetailsViewController.cards[index] = cardAfter
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didDelete card: Card) {
        // Remove card from table view
        for (index, meetingCard) in MeetingDetailsViewController.cards.enumerated() {
            if meetingCard.id == card.id {
                MeetingDetailsViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}

