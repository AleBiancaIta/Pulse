//
//  DashboardViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import DCPathButton
import Parse
import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dcPathButton:DCPathButton!
    
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

        tableView.register(UINib(nibName: "CustomTextCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
        
        let query = PFQuery(className: "Dashboard")
        let userId = (PFUser.current()?.objectId)! as String
        query.whereKey("userId", equalTo: userId)
    
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                if posts.count > 0 {
                    let post = posts[0]
                    self.selectedCardsString = post["selectedCards"] as? String
                } else {
                    self.selectedCardsString = "gtdm" // Default cards (all)
                    let post = PFObject(className: "Dashboard")
                    post["userId"] = userId
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground()
                }
                
                for c in (self.selectedCardsString?.characters)! {
                    switch c {
                    case "g":
                        if !self.selectedCards.contains(Constants.dashboardCards[0]) {
                            self.selectedCards.append(Constants.dashboardCards[0])
                        }
                    case "d":
                        if !self.selectedCards.contains(Constants.dashboardCards[1]) {
                            self.selectedCards.append(Constants.dashboardCards[1])
                        }
                    case "t":
                        if !self.selectedCards.contains(Constants.dashboardCards[2]) {
                            self.selectedCards.append(Constants.dashboardCards[2])
                        }
                    case "m":
                        if !self.selectedCards.contains(Constants.dashboardCards[3]) {
                            self.selectedCards.append(Constants.dashboardCards[3])
                        }
                    default:
                        break
                    }
                }
                
                self.configureDCPathButton()
                self.tableView.reloadData()
                
            } else {
                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error loading dashboard cards, error: \(error?.localizedDescription)")
                //print("error loading dashboard cards")
            }
        }
        
        configureDCPathButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func configureDCPathButton() {
        let size: CGFloat = 40
        let color = UIColor.pulseLightPrimaryColor()
        let highlightColor = UIColor.pulseAccentColor()
        
        var pathImage = UIImage.resizeImageWithSize(image: UIImage(named: "Plus")!, newSize: CGSize(width: size, height: size))
        pathImage = UIImage.recolorImageWithColor(image: pathImage, color: color)
        let pathHighlightedImage = UIImage.recolorImageWithColor(image: pathImage, color: highlightColor)
        dcPathButton = DCPathButton(center: pathImage, highlightedImage: pathHighlightedImage)
        
        dcPathButton.delegate = self
        dcPathButton.dcButtonCenter = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - 25.5)
        dcPathButton.allowSounds = true
        //dcPathButton.allowCenterButtonRotation = true
        dcPathButton.bloomRadius = 80
        
        var chartImage = UIImage.resizeImageWithSize(image: UIImage(named: "PulseGraph")!, newSize: CGSize(width: size, height: size))
        chartImage = UIImage.recolorImageWithColor(image: chartImage, color: color)
        let chartHighlightedImage = UIImage.recolorImageWithColor(image: chartImage, color: highlightColor)
        let chartSelectedImage = selectedCards.contains(Constants.dashboardCards[0]) ? chartHighlightedImage : chartImage
        let chartButton = DCPathItemButton(image: chartSelectedImage, highlightedImage: chartHighlightedImage, backgroundImage: chartImage, backgroundHighlightedImage: chartHighlightedImage)
        
        var toDoImage = UIImage.resizeImageWithSize(image: UIImage(named: "Todo")!, newSize: CGSize(width: size, height: size))
        toDoImage = UIImage.recolorImageWithColor(image: toDoImage, color: color)
        let toDoHighlightedImage = UIImage.recolorImageWithColor(image: toDoImage, color: highlightColor)
        let toDoSelectedImage = selectedCards.contains(Constants.dashboardCards[1]) ? toDoHighlightedImage : toDoImage
        let toDoButton = DCPathItemButton(image: toDoSelectedImage, highlightedImage: toDoHighlightedImage, backgroundImage: toDoImage, backgroundHighlightedImage: toDoHighlightedImage)
        
        var teamImage = UIImage.resizeImageWithSize(image: UIImage(named: "MyTeamDark")!, newSize: CGSize(width: size, height: size))
        teamImage = UIImage.recolorImageWithColor(image: teamImage, color: color)
        let teamHighlightedImage = UIImage.recolorImageWithColor(image: teamImage, color: highlightColor)
        let teamSelectedImage = selectedCards.contains(Constants.dashboardCards[2]) ? teamHighlightedImage : teamImage
        let teamButton = DCPathItemButton(image: teamSelectedImage, highlightedImage: teamHighlightedImage, backgroundImage: teamImage, backgroundHighlightedImage: teamHighlightedImage)
        
        var meetingsImage = UIImage.resizeImageWithSize(image: UIImage(named: "Clipboard")!, newSize: CGSize(width: size, height: size))
        meetingsImage = UIImage.recolorImageWithColor(image: meetingsImage, color: color)
        let meetingsHighlightedImage = UIImage.recolorImageWithColor(image: meetingsImage, color: highlightColor)
        let meetingsSelectedImage = selectedCards.contains(Constants.dashboardCards[3]) ? meetingsHighlightedImage : meetingsImage
        let meetingsButton = DCPathItemButton(image: meetingsSelectedImage, highlightedImage: meetingsHighlightedImage, backgroundImage: meetingsImage, backgroundHighlightedImage: meetingsHighlightedImage)
        
        dcPathButton.addPathItems([chartButton, toDoButton, teamButton, meetingsButton])
        dcPathButton.frame = CGRect(x: view.center.x - size/2, y: UIScreen.main.bounds.height - 64 - 8 - size, width: size, height: size)
        view.addSubview(dcPathButton)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //view.frame.size.height = UIScreen.main.bounds.height - keyboardSize.height - 64
            if view.frame.origin.y != 0 {
                view.frame.origin.y = 0
            }
            view.frame.origin.y -= keyboardSize.height - 64*3
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //view.frame.size.height = UIScreen.main.bounds.height - 64
        self.view.frame.origin.y = 64
    }
    
    // MARK: - IBAction

    @IBAction func onSettingsButtonTap(_ sender: UIBarButtonItem) {
 
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsVC")
        //settingsVC.modalTransitionStyle = .flipHorizontal
        settingsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton(_:)))
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true, completion: nil)
 
        /*
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let settingsNavVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.settingsNavVC) as! UINavigationController
        let settingsVC = settingsNavVC.viewControllers[0] as! SettingsViewController
        settingsVC.modalTransitionStyle = .flipHorizontal
        settingsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButton(_:)))
        self.present(settingsNavVC, animated: true, completion: nil)
        */
    }
    
    @IBAction func onLogoutButtonTap(_ sender: UIBarButtonItem) {
        self.ABIShowAlertWithActions(title: "Alert!", message: "Are you sure you want to log out?", actionTitle1: "Yes", actionTitle2: "No", sender: nil, handler1: { (yesAction: UIAlertAction) in
            self.logOut()
        }, handler2: { (noAction: UIAlertAction) in
            // do nothing
            debugPrint("Cancel logout")
        })
    }
 
    // MARK: - Private Methods
 
    @objc fileprivate func onDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    fileprivate func logOut() {
        /*
         // If anonymous user, give them a heads up that their data will be deleted if they don't sign up
         if PFAnonymousUtils.isLinked(with: user) {
         debugPrint("user is anonymous, give them a warning")
         ABIShowAlertWithActions(title: "Alert", message: "You're currently logged in as anonymous user. To save your data, sign up for an account", actionTitle1: "Sign Up", actionTitle2: "Log Out", sender: nil, handler1: { (alertAction1: UIAlertAction) in
         if alertAction1.title == "Sign Up" {
         debugPrint("Sign Up is being clicked")
         self.segueToStoryboard(id: StoryboardID.signupVC)
         }
         }, handler2: { (alertAction2: UIAlertAction) in
         if alertAction2.title == "Log Out" {
         debugPrint("Log Out is being clicked")
         PFUser.logOutInBackground(block: { (error: Error?) in
         if let error = error {
         debugPrint("Log out failed with error: \(error.localizedDescription)")
         } else {
         debugPrint("User log out successfully")
         self.segueToStoryboard(id: StoryboardID.loginSignupVC)
         }
         })
         }
         })
         } else { */
        // If not anonymous, log out user and take them back to the sign up page
        PFUser.logOutInBackground { (error: Error?) in
            if let error = error {
                debugPrint("Log out failed with error: \(error.localizedDescription)")
            } else {
                debugPrint("User log out successfully")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Logout"), object: self, userInfo: nil)
                //self.segueToStoryboard(id: StoryboardID.loginSignupVC)
            }
        }
        //}
    }
    
    fileprivate func segueToStoryboard(id: String) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginSignUpVC = storyboard.instantiateViewController(withIdentifier: id)
        self.present(loginSignUpVC, animated: true, completion: nil)
        //(UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = loginSignUpVC
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DashboardViewController: UIGestureRecognizerDelegate {
    // Do nothing
}

// MARK: - UITableViewDataSource

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedCards[indexPath.section].id! {
        case "g":
            let cell = tableView.dequeueReusableCell(withIdentifier: "GraphContainerCell", for: indexPath)
            cell.selectionStyle = .none
            cell.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            
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
            cell.backgroundColor = UIColor.clear
            
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! CustomTextCell
            cell.layer.cornerRadius = 5
            cell.message = selectedCards[indexPath.section].name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedCards.count
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
    }
}

extension DashboardViewController: DCPathButtonDelegate {
    func didDismissDCPathButtonItems(_ dcPathButton: DCPathButton!) {
        if !dcPathButton.isDescendant(of: view) {
            configureDCPathButton()
        } else {
            dcPathButton.removeFromSuperview()
            configureDCPathButton()
        }
    }
    
    func pathButton(_ dcPathButton: DCPathButton!, clickItemButtonAt itemButtonIndex: UInt) {
        let card = Constants.dashboardCards[Int(itemButtonIndex)]
        
        if selectedCards.contains(card) {
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
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error removing dashboard card, error: \(error?.localizedDescription)")
                    //print("error removing dashboard card")
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
            
        } else {
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
                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving dashboard card, error: \(error?.localizedDescription)")
                            //print("error saving dashboard card")
                        }
                    }
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving dashboard card, error: \(error?.localizedDescription)")
                    //print("error saving dashboard card")
                }
            }
            
            // Insert new card at the top of the table view
            if !selectedCards.contains(card) {
                selectedCards.insert(card, at: 0)
            }
            tableView.reloadData()
            tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
        }
    }
}
