//
//  SkeletonViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class SkeletonViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
    static var cards: [Card] = [] // TODO put in data controller, then abstract this so it's a true skeleton VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.register(UINib(nibName: "CardCellNib", bundle: nil), forCellReuseIdentifier: "CardCell")
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
    }
    
    // MARK: - IBAction
    
    @IBAction func onAddCard(_ sender: UIBarButtonItem) {
        guard SkeletonViewController.cards.count != Card.cards.count else {
            alertController.message = "You already have all the cards"
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alertController, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectionNavigationController = storyboard.instantiateViewController(withIdentifier: "SelectionNavigationController") as! UINavigationController
        
        if let selectionViewController = selectionNavigationController.topViewController as? SelectionViewController {
            selectionViewController.delegate = self
        }
        
        present(selectionNavigationController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension SkeletonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // No cards
        if SkeletonViewController.cards.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.message = "Tap the + button to add cards"
            return cell
        
        // Last section
        } else if indexPath.section == numberOfSections(in: tableView) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.message = "Tap the + button to add a new 1:1 meeting, or long press the + button to add cards"
            return cell
        
        // TODO replace the cells with the actual view
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
            cell.delegate = self
            cell.card = SkeletonViewController.cards[indexPath.section]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SkeletonViewController.cards.count + 1
    }
    
    /*func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            SkeletonViewController.cards.remove(at: indexPath.section)
            tableView.reloadData()
        }
    }*/
}

// MARK: - UITableViewDelegate

extension SkeletonViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SelectionViewControllerDelegate

extension SkeletonViewController: SelectionViewControllerDelegate {
    
    func selectionViewController(selectionViewController: SelectionViewController, didAddCard card: Card) {
        // Insert new card at the top of the table view
        SkeletonViewController.cards.insert(card, at: 0)
        tableView.reloadData()
    }
    
    func selectionViewController(selectionViewController: SelectionViewController, didRemoveCard card: Card) {
        // Remove card from table view
        for (index, dashboardCard) in SkeletonViewController.cards.enumerated() {
            if dashboardCard.id == card.id {
                SkeletonViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - CardCellDelegate

extension SkeletonViewController: CardCellDelegate {
    func cardCell(cardCell: CardCell, didMoveUp card: Card) {
        
    }
    
    func cardCell(cardCell: CardCell, didMoveDown card: Card) {
        
    }
    
    func cardCell(cardCell: CardCell, didDelete card: Card) {
        // Remove card from table view
        for (index, dashboardCard) in SkeletonViewController.cards.enumerated() {
            if dashboardCard.id == card.id {
                SkeletonViewController.cards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}
