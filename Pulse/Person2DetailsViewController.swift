//
//  Person2DetailsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/23/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit

class Person2DetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var alertController: UIAlertController?
    
    var selectedCardsString: String? = ""
    var selectedCards: [Card] = []
    
    var personPFObject: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        alertController = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        loadExistingPerson()
    }

    func loadExistingPerson() {
        // Existing person
        if nil != self.personPFObject,
            let personPFObject = self.personPFObject {
            let firstName =  personPFObject[ObjectKeys.Person.firstName] as! String
            let lastName = personPFObject[ObjectKeys.Person.lastName] as! String
            self.title = "\(firstName) \(lastName)"
            
            if let selectedCardsString = personPFObject[ObjectKeys.Person.selectedCards] as? String {
                self.selectedCardsString = selectedCardsString
                for c in selectedCardsString.characters {
                    switch c {
                    case "d":
                        selectedCards.append(Constants.personCards[0])
                    case "n":
                        selectedCards.append(Constants.personCards[1])
                    //case "p":
                    //    selectedCards.append(Constants.personCards[2])
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @objc fileprivate func resetCell(_ cell: UITableViewCell) {
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
    }
}

extension Person2DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == selectedCards.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.message = "Tap here to manage cards"
            return cell
            
        } else { // The actual cards
            switch selectedCards[indexPath.row].id! {
            case "d":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                resetCell(cell)
                let storyboard = UIStoryboard(name: "Todo", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
                viewController.currentTeamPerson = personPFObject
                viewController.viewTypes = .employeeDetail
                self.addChildViewController(viewController)
                cell.contentView.addSubview(viewController.view)
                return cell
                
            case "n":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                resetCell(cell)
                let storyboard = UIStoryboard(name: "Notes", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
                viewController.delegate = self
                if let personPFObject = personPFObject,
                    let notes = personPFObject["notes"] as? String {
                    viewController.notes = notes
                }
                self.addChildViewController(viewController)
                cell.contentView.addSubview(viewController.view)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                resetCell(cell)
                cell.textLabel?.text = selectedCards[indexPath.row].name
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCards.count + 1
    }
    
    func onManageCards() {
        let storyboard = UIStoryboard(name: "Person2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PersonDetailsSelectionViewController") as! PersonDetailsSelectionViewController
        viewController.delegate = self
        viewController.selectedCards = selectedCards
        let navController = UINavigationController(rootViewController: viewController)
        present(navController, animated: true, completion: nil)
    }
}

extension Person2DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let defaultHeight: CGFloat = 44
        guard indexPath.row < selectedCards.count else {
            return defaultHeight
        }
        
        switch selectedCards[indexPath.row].id! {
        case "d":
            let storyboard = UIStoryboard(name: "Todo", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
            return viewController.heightForView()
            
        case "n":
            let storyboard = UIStoryboard(name: "Notes", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
            return viewController.heightForView()
            
        default:
            return defaultHeight
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == selectedCards.count {
            onManageCards()
        }
    }
}

// MARK: - PersonDetailsSelectionViewControllerDelegate

extension Person2DetailsViewController: PersonDetailsSelectionViewControllerDelegate {
    
    func personDetailsSelectionViewController(personDetailsSelectionViewController: PersonDetailsSelectionViewController, didAddCard card: Card) {
        let query = PFQuery(className: "Person")
        if let personPFObject = personPFObject,
            let personId = personPFObject.objectId {
            query.whereKey("objectId", equalTo: personId)
        }
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = "\(id)\(selectedCardsString)"
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground { (success: Bool, error: Error?) in
                        if success {
                            print("successfully saved person card")
                        } else {
                            print("error saving person card")
                        }
                    }
                } else {
                    let post = PFObject(className: "Person")
                    post["selectedCards"] = selectedCardsString
                    post.saveInBackground()
                }
            } else {
                print("error saving person card")
            }
        }
        
        // Insert new card at the top of the table view
        selectedCards.insert(card, at: 0)
        tableView.reloadData()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
    }
    
    func personDetailsSelectionViewController(personDetailsSelectionViewController: PersonDetailsSelectionViewController, didRemoveCard card: Card) {
        
        let query = PFQuery(className: "Person")
        if let personPFObject = personPFObject,
            let personId = personPFObject.objectId {
            query.whereKey("objectId", equalTo: personId)
        }
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = selectedCardsString.replacingOccurrences(of: id, with: "")
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground { (success: Bool, error: Error?) in
                        print("successfully removed person card")
                    }
                }
            } else {
                print("error removing person card")
            }
        }
        
        // Remove card from table view
        for (index, personCard) in selectedCards.enumerated() {
            if personCard.id == card.id {
                selectedCards.remove(at: index)
            }
        }
        tableView.reloadData()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
    }
}

extension Person2DetailsViewController: NotesViewControllerDelegate {
    func notesViewController(notesViewController: NotesViewController, didUpdateNotes notes: String) {
        if let personPFObject = personPFObject {
            personPFObject["notes"] = notes
        }
    }
}

