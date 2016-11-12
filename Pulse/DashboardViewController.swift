//
//  DashboardViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var alertController: UIAlertController?
    static var cards: [Card] = [] // TODO put in data controller, then abstract this so it's a true skeleton VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.register(UINib(nibName: "CardCellNib", bundle: nil), forCellReuseIdentifier: "CardCell")
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "OK", style: .cancel))
    }
    
    // MARK: - IBAction
    
    @IBAction func onAddCard(_ sender: UIBarButtonItem) {
        guard DashboardViewController.cards.count != Constants.dashboardCards.count else {
            alertController?.message = "You already have all the cards"
            present(alertController!, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardSelectionNavigationController = storyboard.instantiateViewController(withIdentifier: "DashboardSelectionNavigationController") as! UINavigationController
        
        if let dashboardSelectionViewController = dashboardSelectionNavigationController.topViewController as? DashboardSelectionViewController {
            dashboardSelectionViewController.delegate = self
        }
        
        present(dashboardSelectionNavigationController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // No cards
        if DashboardViewController.cards.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.message = "Tap the + button to add cards"
            cell.isUserInteractionEnabled = false
            return cell
        
        // Last section
        } else if indexPath.section == numberOfSections(in: tableView) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.message = "Tap the + button to add a new 1:1 meeting, or long press the + button to add cards"
            cell.isUserInteractionEnabled = false
            return cell
        
        // TODO replace the cells with the actual view
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
            cell.delegate = self
            cell.card = DashboardViewController.cards[indexPath.section]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DashboardViewController.cards.count + 1
    }
    
    /*func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            DashboardViewController.cards.remove(at: indexPath.section)
            tableView.reloadData()
        }
    }*/
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard DashboardViewController.cards.count > section else {
            return nil
        }
        return DashboardViewController.cards[section].name
    }
}

// MARK: - UITableViewDelegate

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard nil != self.tableView(tableView, titleForHeaderInSection: section) else {
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? CardCell,
            let card = cell.card,
            let cardType = card.cardType {
            
            switch cardType {
            case "meeting":
                navigationController?.pushViewController(MeetingDetailsViewController(), animated: true)
            default:
                break
            }
        }
    }
}

// MARK: - DashboardSelectionViewControllerDelegate

extension DashboardViewController: DashboardSelectionViewControllerDelegate {
    
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didAddCard card: Card) {
        // Insert new card at the top of the table view
        DashboardViewController.cards.insert(card, at: 0)
        tableView.reloadData()
    }
    
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didRemoveCard card: Card) {
        // Remove card from table view
        for (index, dashboardCard) in DashboardViewController.cards.enumerated() {
            if dashboardCard.id == card.id {
                DashboardViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - CardCellDelegate

extension DashboardViewController: CardCellDelegate {
    func cardCell(cardCell: CardCell, didMoveUp card: Card) {
        for (index, dashboardCard) in DashboardViewController.cards.enumerated() {
            if dashboardCard.id == card.id {
                
                // First card
                guard index != 0 else {
                    alertController?.message = "This card cannot move up further"
                    present(alertController!, animated: true)
                    return
                }
            
                // Swap with card before
                let cardBefore = DashboardViewController.cards[index-1]
                DashboardViewController.cards[index-1] = card
                DashboardViewController.cards[index] = cardBefore
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didMoveDown card: Card) {
        for (index, dashboardCard) in DashboardViewController.cards.enumerated() {
            if dashboardCard.id == card.id { // TODO find better way to do this
                
                // Last card
                guard index < DashboardViewController.cards.count - 1 else {
                    alertController?.message = "This card cannot move down further"
                    present(alertController!, animated: true)
                    return
                }
                
                // Swap with card after
                let cardAfter = DashboardViewController.cards[index+1]
                DashboardViewController.cards[index+1] = card
                DashboardViewController.cards[index] = cardAfter
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didDelete card: Card) {
        // Remove card from table view
        for (index, dashboardCard) in DashboardViewController.cards.enumerated() {
            if dashboardCard.id == card.id {
                DashboardViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}