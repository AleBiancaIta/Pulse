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

        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        alertController = UIAlertController(title: "Error", message: "Error", preferredStyle: .alert)
        alertController?.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        let query = PFQuery(className: "Dashboard")
        let userId = (PFUser.current()?.objectId)! as String
        query.whereKey("userId", equalTo: userId)
    
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = post["selectedCards"] as? String
                    for c in (self.selectedCardsString?.characters)! {
                        switch c {
                        case "m":
                            self.selectedCards.append(Constants.dashboardCards[0])
                        case "g":
                            self.selectedCards.append(Constants.dashboardCards[1])
                        case "t":
                            self.selectedCards.append(Constants.dashboardCards[2])
                        case "d":
                            self.selectedCards.append(Constants.dashboardCards[3])
                        default:
                            break
                        }
                    }
                } else {
                    let post = PFObject(className: "Dashboard")
                    post["userId"] = userId
                    post["selectedCards"] = ""
                    post.saveInBackground()
                }
                self.tableView.reloadData()
                
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    // MARK: - IBAction
    
    func onAddCard() {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DashboardSelectionViewController") as! DashboardSelectionViewController
        viewController.delegate = self
        viewController.selectedCards = selectedCards
        let navController = UINavigationController(rootViewController: viewController)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func onSettingsButtonTap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsVC")
        settingsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton(_:)))
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
    }
 
    // MARK: - Private Methods
 
    @objc fileprivate func onDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DashboardViewController: UIGestureRecognizerDelegate {
    // Do nothing
}

// MARK: - UITableViewDataSource

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == selectedCards.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.message = "Tap here to manage cards"
            return cell
        
        // The actual cards
        } else {
            switch selectedCards[indexPath.row].id! {
            case "g":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                let storyboard = UIStoryboard(name: "Graph", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GraphViewController")
                self.addChildViewController(vc)
                cell.contentView.addSubview(vc.view)
                return cell
                
            case "m":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MeetingsViewController")
                self.addChildViewController(vc)
                cell.contentView.addSubview(vc.view)
                return cell
                
            case "t":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                let storyboard = UIStoryboard(name: "Team", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TeamCollectionVC")
                self.addChildViewController(vc)
                cell.contentView.addSubview(vc.view)
                return cell
                
            case "d":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                let storyboard = UIStoryboard(name: "Todo", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TodoVC")
                self.addChildViewController(vc)
                cell.contentView.addSubview(vc.view)
                return cell

            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContainerCell", for: indexPath)
                for subview in cell.contentView.subviews  {
                    subview.removeFromSuperview() // Reset subviews
                }
                cell.textLabel?.text = selectedCards[indexPath.row].name
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCards.count + 1
    }
}

// MARK: - UITableViewDelegate

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let defaultHeight: CGFloat = 44
        guard indexPath.row < selectedCards.count else {
            return defaultHeight
        }
        
        switch selectedCards[indexPath.row].id! {
        case "g":
            let storyboard = UIStoryboard(name: "Graph", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "GraphViewController") as! GraphViewController
            return viewController.heightForView()
            
        case "m":
            let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingsViewController") as! MeetingsViewController
            return viewController.heightForView()
            
        case "t":
            let storyboard = UIStoryboard(name: "Team", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TeamCollectionVC") as! TeamCollectionViewController
            return viewController.heightForView()
            
        case "d":
            let storyboard = UIStoryboard(name: "Todo", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
            return viewController.heightForView()
            
        default:
            return defaultHeight
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == selectedCards.count {
            onAddCard()
        }
    }
}

// MARK: - DashboardSelectionViewControllerDelegate

extension DashboardViewController: DashboardSelectionViewControllerDelegate {
    
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didAddCard card: Card) {
        
        let query = PFQuery(className: "Dashboard")
        let userId = (PFUser.current()?.objectId)! as String
        query.whereKey("userId", equalTo: userId)
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                let post = posts[0]
                post["userId"] = userId
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
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
    }
    
    func dashboardSelectionViewController(dashboardSelectionViewController: DashboardSelectionViewController, didRemoveCard card: Card) {
        
        let query = PFQuery(className: "Dashboard")
        let userId = (PFUser.current()?.objectId)! as String
        query.whereKey("userId", equalTo: userId)
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
                let id = card.id,
                let selectedCardsString = self.selectedCardsString {
                let post = posts[0]
                post["userId"] = userId
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
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
    }
}

