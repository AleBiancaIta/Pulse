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
        
        UIExtensions.gradientBackgroundFor(view: view)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        alertController = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
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
                print("error loading dashboard cards")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.size.height = UIScreen.main.bounds.height - keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.size.height = UIScreen.main.bounds.height
    }
    
    // MARK: - IBAction
    
    func onManageCards() {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DashboardSelectionViewController") as! DashboardSelectionViewController
        viewController.delegate = self
        viewController.selectedCards = selectedCards
        present(viewController, animated: true, completion: nil)
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
        
        if indexPath.section == selectedCards.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.layer.cornerRadius = 5
            cell.message = "Tap here to manage cards"
            return cell
        
        // The actual cards - TODO pull this out to separate functions
        } else {
            switch selectedCards[indexPath.section].id! {
            case "g":
                let cell = tableView.dequeueReusableCell(withIdentifier: "GraphContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Graph", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "GraphViewController") as! GraphViewController
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                
                return cell
                
            case "m":
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingsContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingsViewController") as! MeetingsViewController
                    viewController.personId = nil
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                
                return cell
                
            case "t":
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Team", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "TeamCollectionVC") as! TeamCollectionViewController
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                    
                return cell
                
            case "d":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                
                if cell.contentView.subviews == [] {
                    let storyboard = UIStoryboard(name: "Todo", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    cell.contentView.addSubview(viewController.view)
                    self.addChildViewController(viewController)
                    viewController.didMove(toParentViewController: self)
                }
                
                return cell

            default: // This shouldn't actually be reached
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
                cell.layer.cornerRadius = 5
                cell.message = selectedCards[indexPath.section].name
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedCards.count + 1
    }
}

// MARK: - UITableViewDelegate

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let defaultHeight: CGFloat = 44
        guard indexPath.section < selectedCards.count else {
            return defaultHeight
        }
        
        switch selectedCards[indexPath.section].id! {
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
        
        if indexPath.section == selectedCards.count {
            onManageCards()
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
                        print("error saving dashboard card")
                    }
                }
            } else {
                print("error saving dashboard card")
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
                print("error removing dashboard card")
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

