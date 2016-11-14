//
//  DashboardViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var alertController: UIAlertController?
    
    var selectedCardsString: String? = ""
    var selectedCards: [Card] = []
    
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
        
        let query = PFQuery(className: "Dashboard")
        query.whereKey("userId", equalTo: "BiancaTest") // TODO logged in casePFUser.current()?.objectId
    
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                let post = posts[0]
                self.selectedCardsString = post["selectedCards"] as? String
                for c in (self.selectedCardsString?.characters)! {
                    switch c {
                    /* TODO case "m":
                        self.selectedCards.append(Constants.dashboardCards[0])*/
                    /* TODO case "g":
                        self.selectedCards.append(Constants.dashboardCards[1])*/
                    case "t":
                        self.selectedCards.append(Constants.dashboardCards[0])
                    case "d":
                        self.selectedCards.append(Constants.dashboardCards[1])
                    default:
                        break
                    }
                }
                self.tableView.reloadData()
                
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func onAddMeeting(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(MeetingDetailsViewController(), animated: true)
    }
    
    func onAddCard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dashboardSelectionNavigationController = storyboard.instantiateViewController(withIdentifier: "DashboardSelectionNavigationController") as! UINavigationController
        
        if let dashboardSelectionViewController = dashboardSelectionNavigationController.topViewController as? DashboardSelectionViewController {
            dashboardSelectionViewController.delegate = self
            dashboardSelectionViewController.selectedCards = selectedCards
        }
        
        present(dashboardSelectionNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func onSettingsButtonTap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsVC")
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension DashboardViewController: UIGestureRecognizerDelegate {
    // Do nothing
}

// MARK: - UITableViewDataSource

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == numberOfSections(in: tableView) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.message = "Tap here to manage cards"
            return cell
        
        // The actual cards
        } else {
            /*let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
            cell.delegate = self
            cell.card = selectedCards[indexPath.section]
            return cell*/
            let cell = tableView.dequeueReusableCell(withIdentifier: "TempCell", for: indexPath)
            cell.textLabel?.text = selectedCards[indexPath.section].name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedCards.count + 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard selectedCards.count > section else {
            return nil
        }
        return selectedCards[section].name
    }
}

// MARK: - UITableViewDelegate

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //guard nil != self.tableView(tableView, titleForHeaderInSection: section) else {
            return 0
        //}
        //return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == numberOfSections(in: tableView) - 1 {
            onAddCard()
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if self.tableView(tableView, titleForHeaderInSection: indexPath.section) == "Meetings" {
                navigationController?.pushViewController(MeetingsViewController(), animated: true)
            } else if self.tableView(tableView, titleForHeaderInSection: indexPath.section) == "Team Members"{
                let storyboard = UIStoryboard(name: "Team", bundle: nil)
                let viewController = storyboard.instantiateInitialViewController()
                navigationController?.pushViewController(viewController!, animated: true)
            }
        }
        
        /*if let cell = tableView.cellForRow(at: indexPath) as? CardCell,
            let card = cell.card,
            let cardType = card.cardType {
            
            switch cardType {
            /* TODO case "meetings":
                navigationController?.pushViewController(MeetingDetailsViewController(), animated: true)*/
            default:
                break
            }
        }*/
    }
}

// MARK: - DashboardSelectionViewControllerDelegate

extension DashboardViewController: DashboardSelectionViewControllerDelegate {
    
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didAddCard card: Card) {
        
        let query = PFQuery(className: "Dashboard")
        query.whereKey("userId", equalTo: "BiancaTest") // TODO PFUser.current()?.objectId
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                let post = posts[0]
                post["userId"] = "BiancaTest" // TODO PFUser.current()?.objectId
                self.selectedCardsString = "\(id)\(selectedCardsString)"
                post["selectedCards"] = self.selectedCardsString
                post.saveInBackground { (success: Bool, error: Error?) in
                    if success {
                        print("successfully saved dashboard card")
                    } else {
                        print(error?.localizedDescription)
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // Insert new card at the top of the table view
        selectedCards.insert(card, at: 0)
        tableView.reloadData()
    }
    
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didRemoveCard card: Card) {
        
        let query = PFQuery(className: "Dashboard")
        query.whereKey("userId", equalTo: "BiancaTest") // TODO PFUser.current()?.objectId
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                let post = posts[0]
                post["userId"] = "BiancaTest" // TODO PFUser.current()?.objectId
                self.selectedCardsString = selectedCardsString.replacingOccurrences(of: id, with: "")
                post["selectedCards"] = self.selectedCardsString
                post.saveInBackground { (success: Bool, error: Error?) in
                    print("successfully removed dashboard card")
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // Remove card from table view
        for (index, dashboardCard) in selectedCards.enumerated() {
            if dashboardCard.id == card.id {
                selectedCards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - CardCellDelegate

extension DashboardViewController: CardCellDelegate {
    func cardCell(cardCell: CardCell, didMoveUp card: Card) {
        for (index, dashboardCard) in selectedCards.enumerated() {
            if dashboardCard.id == card.id {
                
                // First card
                guard index != 0 else {
                    alertController?.message = "This card cannot move up further"
                    present(alertController!, animated: true)
                    return
                }
            
                let query = PFQuery(className: "Dashboard")
                query.whereKey("userId", equalTo: "BiancaTest") // TODO PFUser.current()?.objectId
                query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                    if let posts = posts,
                        let selectedCardsString = self.selectedCardsString {
                        let post = posts[0]
                        post["userId"] = "BiancaTest" // TODO PFUser.current()?.objectId
                        
                        var characters = Array(selectedCardsString.characters)
                        let charBefore = characters[index-1]
                        characters[index-1] = characters[index]
                        characters[index] = charBefore
                        self.selectedCardsString = String(characters)
                        
                        post["selectedCards"] = self.selectedCardsString
                        post.saveInBackground { (success: Bool, error: Error?) in
                            print("successfully moved up dashboard card")
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                }
                
                // Swap with card before
                let cardBefore = selectedCards[index-1]
                selectedCards[index-1] = card
                selectedCards[index] = cardBefore
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didMoveDown card: Card) {
        for (index, dashboardCard) in selectedCards.enumerated() {
            if dashboardCard.id == card.id { // TODO find better way to do this
                
                // Last card
                guard index < selectedCards.count - 1 else {
                    alertController?.message = "This card cannot move down further"
                    present(alertController!, animated: true)
                    return
                }
                
                let query = PFQuery(className: "Dashboard")
                query.whereKey("userId", equalTo: "BiancaTest") // TODO PFUser.current()?.objectId
                query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                    if let posts = posts,
                        let selectedCardsString = self.selectedCardsString {
                        let post = posts[0]
                        post["userId"] = "BiancaTest" // TODO PFUser.current()?.objectId
                        
                        var characters = Array(selectedCardsString.characters)
                        let charAfter = characters[index+1]
                        characters[index+1] = characters[index]
                        characters[index] = charAfter
                        self.selectedCardsString = String(characters)
                        
                        post["selectedCards"] = self.selectedCardsString
                        post.saveInBackground { (success: Bool, error: Error?) in
                            print("successfully moved up dashboard card")
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                }
                
                // Swap with card after
                let cardAfter = selectedCards[index+1]
                selectedCards[index+1] = card
                selectedCards[index] = cardAfter
                tableView.reloadData()
            }
        }
    }
    
    func cardCell(cardCell: CardCell, didDelete card: Card) {
        let query = PFQuery(className: "Dashboard")
        query.whereKey("userId", equalTo: "BiancaTest") // TODO PFUser.current()?.objectId
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                let post = posts[0]
                post["userId"] = "BiancaTest" // TODO PFUser.current()?.objectId
                self.selectedCardsString = selectedCardsString.replacingOccurrences(of: id, with: "")
                post["selectedCards"] = self.selectedCardsString
                post.saveInBackground { (success: Bool, error: Error?) in
                    print("successfully removed dashboard card")
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // Remove card from table view
        for (index, dashboardCard) in selectedCards.enumerated() {
            if dashboardCard.id == card.id {
                selectedCards.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}
