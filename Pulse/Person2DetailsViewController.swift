//
//  Person2DetailsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/23/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import DCPathButton
import Parse
import UIKit

class Person2DetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dcPathButton:DCPathButton!
    
    var selectedCardsString: String = ""
//    var selectedCardsString: String = "dm" // Default cards (To Do, Meetings)
    var selectedCards: [Card] = [Constants.personCards[0]] // Always include info card
    
    var personPFObject: PFObject?
	var personInfoViewController: PersonDetailsViewController!
    var personManagerId: String?
    var userPersonId: String?
    
    var isPersonManager: Bool = false
    
    fileprivate let parseClient = ParseClient.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIExtensions.gradientBackgroundFor(view: view)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: "CustomTextCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
        
		initPersonInfo()
        
        // Hide card functionality if not existing person
        if let personPFObject = personPFObject,
            let managerId = personPFObject["managerId"] as? String {
            parseClient.getCurrentPerson { (person: PFObject?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.personManagerId = managerId
                    if let person = person, managerId == person.objectId {
                        self.configureDCPathButton()
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        /*
        // If person is a manager or above, include team card
        if let personObject = personPFObject, let positionId = personObject[ObjectKeys.Person.positionId] as? String {
            debugPrint("positionId is \(positionId)")
            if positionId != "1" {
                self.selectedCards.append(Constants.personCards[1])
                self.isPersonManager = true
            }
        }*/
        
        /*
        if let person = personPFObject, let positionId = person[ObjectKeys.Person.positionId] as? String {
            debugPrint("positionId is \(positionId)")
            hasDirectReport(manager: person) { (isManager: Bool, error: Error?) in
                if isManager {
                    self.selectedCards.append(Constants.personCards[1])
                    self.isPersonManager = true
                    self.loadExistingPerson()
                } else {
                    if let error = error {
                        debugPrint("hasDirectReport returned error: \(error.localizedDescription)")
                    }
                    
                    self.loadExistingPerson()
                }
            }
        }*/
        
        if isPersonManager {
            self.selectedCards.append(Constants.personCards[1])
        }
    
        loadSelectedCards()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //view.frame.size.height = UIScreen.main.bounds.height - keyboardSize.height - 64
            if view.frame.origin.y != 0 {
                view.frame.origin.y = 0
            }
            view.frame.origin.y -= keyboardSize.height - 64*2
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //view.frame.size.height = UIScreen.main.bounds.height - 64
        view.frame.origin.y = 64
    }
    
//    fileprivate func hasDirectReport(manager: PFObject, isManager: @escaping (Bool, Error?)->())  {
//        let managerId = manager.objectId!
//        
//        parseClient.fetchTeamMembersFor(managerId: managerId, isAscending1: nil, isAscending2: nil, orderBy1: nil, orderBy2: nil, isDeleted: false) { (teams: [PFObject]?, error: Error?) in
//            if let error = error {
//                debugPrint("Failed to fetch team members")
//                isManager(false, error)
//            } else {
//                if let teams = teams, teams.count > 0 {
//                    isManager(true, nil)
//                } else {
//                    isManager(false, nil)
//                }
//            }
//        }
//    }

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
        dcPathButton.bloomRadius = 100
        
        var infoImage = UIImage.resizeImageWithSize(image: UIImage(named: "DriverLicense")!, newSize: CGSize(width: size, height: size))
        infoImage = UIImage.recolorImageWithColor(image: infoImage, color: color)
        let infoHighlightedImage = UIImage.recolorImageWithColor(image: infoImage, color: highlightColor)
        let infoSelectedImage = selectedCards.contains(Constants.personCards[0]) ? infoHighlightedImage : infoImage
        let infoButton = DCPathItemButton(image: infoSelectedImage, highlightedImage: infoHighlightedImage, backgroundImage: infoImage, backgroundHighlightedImage: infoHighlightedImage)
        
        var teamImage = UIImage.resizeImageWithSize(image: UIImage(named: "MyTeamDark")!, newSize: CGSize(width: size, height: size))
        teamImage = UIImage.recolorImageWithColor(image: teamImage, color: color)
        let teamHighlightedImage = UIImage.recolorImageWithColor(image: teamImage, color: highlightColor)
        let teamSelectedImage = selectedCards.contains(Constants.personCards[1]) ? teamHighlightedImage : teamImage
        let teamButton = DCPathItemButton(image: teamSelectedImage, highlightedImage: teamHighlightedImage, backgroundImage: teamImage, backgroundHighlightedImage: teamHighlightedImage)
        
        var toDoImage = UIImage.resizeImageWithSize(image: UIImage(named: "Todo")!, newSize: CGSize(width: size, height: size))
        toDoImage = UIImage.recolorImageWithColor(image: toDoImage, color: color)
        let toDoHighlightedImage = UIImage.recolorImageWithColor(image: toDoImage, color: highlightColor)
        let toDoSelectedImage = selectedCards.contains(Constants.personCards[2]) ? toDoHighlightedImage : toDoImage
        let toDoButton = DCPathItemButton(image: toDoSelectedImage, highlightedImage: toDoHighlightedImage, backgroundImage: toDoImage, backgroundHighlightedImage: toDoHighlightedImage)
        
        var meetingsImage = UIImage.resizeImageWithSize(image: UIImage(named: "Clipboard")!, newSize: CGSize(width: size, height: size))
        meetingsImage = UIImage.recolorImageWithColor(image: meetingsImage, color: color)
        let meetingsHighlightedImage = UIImage.recolorImageWithColor(image: meetingsImage, color: highlightColor)
        let meetingsSelectedImage = selectedCards.contains(Constants.personCards[3]) ? meetingsHighlightedImage : meetingsImage
        let meetingsButton = DCPathItemButton(image: meetingsSelectedImage, highlightedImage: meetingsHighlightedImage, backgroundImage: meetingsImage, backgroundHighlightedImage: meetingsHighlightedImage)
        
        var notesImage = UIImage.resizeImageWithSize(image: UIImage(named: "DoublePaper")!, newSize: CGSize(width: size, height: size))
        notesImage = UIImage.recolorImageWithColor(image: notesImage, color: color)
        let notesHighlightedImage = UIImage.recolorImageWithColor(image: notesImage, color: highlightColor)
        let notesSelectedImage = selectedCards.contains(Constants.personCards[4]) ? notesHighlightedImage : notesImage
        let notesButton = DCPathItemButton(image: notesSelectedImage, highlightedImage: notesHighlightedImage, backgroundImage: notesImage, backgroundHighlightedImage: notesHighlightedImage)
        
        dcPathButton.addPathItems([infoButton, teamButton, toDoButton, meetingsButton, notesButton])
        dcPathButton.frame = CGRect(x: view.center.x - size/2, y: UIScreen.main.bounds.height - 64 - 8 - size, width: size, height: size)
        view.addSubview(dcPathButton)
    }
    
	func initPersonInfo() {

		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onRightBarButtonTap(_:)))

		let storyboard = UIStoryboard(name: "Person", bundle: nil)
		personInfoViewController = storyboard.instantiateViewController(withIdentifier: "PersonDetailsViewController") as! PersonDetailsViewController
		personInfoViewController.personPFObject = personPFObject
		personInfoViewController.personInfoParentViewController = self
	}

	func onRightBarButtonTap(_ sender: UIBarButtonItem) {
		personInfoViewController.onRightBarButtonTap(sender)
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		navigationItem.rightBarButtonItem?.title = editing ? "Save" : "Edit"
	}

    func loadSelectedCards() {
        // Existing person
        if nil != self.personPFObject,
            let personPFObject = self.personPFObject {
            
            let firstName =  personPFObject[ObjectKeys.Person.firstName] as! String
            let lastName = personPFObject[ObjectKeys.Person.lastName] as! String
            self.title = firstName != lastName ? "\(firstName) \(lastName)" : firstName
            
            if let selectedCardsString = personPFObject[ObjectKeys.Person.selectedCards] as? String {
                self.selectedCardsString = selectedCardsString
            }
            
        }
        
        for c in selectedCardsString.characters {
            switch c {
            case "d":
                if !self.selectedCards.contains(Constants.personCards[2]) {
                    selectedCards.append(Constants.personCards[2])
                }
            case "m":
                if !self.selectedCards.contains(Constants.personCards[3]) {
                    selectedCards.append(Constants.personCards[3])
                }
            case "n":
                if !self.selectedCards.contains(Constants.personCards[4]) {
                    selectedCards.append(Constants.personCards[4])
                }
            default:
                break
            }
        }
    }
}

extension Person2DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedCards[indexPath.section].id! {
        case "i": 
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoContainerCell", for: indexPath)
            cell.selectionStyle = .none
            cell.layer.cornerRadius = 5
            
            if cell.contentView.subviews == [] {
                personInfoViewController.willMove(toParentViewController: self)
                personInfoViewController.view.frame = CGRect(x: 0, y: 0, width: personInfoViewController.view.frame.size.width, height: personInfoViewController.heightForView())
                cell.contentView.addSubview(personInfoViewController.view)
                self.addChildViewController(personInfoViewController)
                personInfoViewController.didMove(toParentViewController: self)
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
                viewController.person = personPFObject
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
                viewController.currentTeamPerson = personPFObject
                viewController.viewTypes = .employeeDetail
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
                if let personPFObject = personPFObject {
                    viewController.personId = personPFObject.objectId
                }
                viewController.viewTypes = .employeeDetail
                viewController.willMove(toParentViewController: self)
                viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                cell.contentView.addSubview(viewController.view)
                self.addChildViewController(viewController)
                viewController.didMove(toParentViewController: self)
            }
            
            return cell
            
        case "n":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesContainerCell", for: indexPath)
            cell.selectionStyle = .none
            cell.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            
            if cell.contentView.subviews == [] {
                let storyboard = UIStoryboard(name: "Notes", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
                viewController.delegate = self
                if let personPFObject = personPFObject,
                    let notes = personPFObject["notes"] as? String {
                    viewController.notes = notes
                }
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

extension Person2DetailsViewController: UITableViewDelegate {
    
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
		case "i":
			let storyboard = UIStoryboard(name: "Person", bundle: nil)
			let viewController = storyboard.instantiateViewController(withIdentifier: "PersonDetailsViewController") as! PersonDetailsViewController
			return viewController.heightForView()
            
        case "t":
            let storyboard = UIStoryboard(name: "Team", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TeamCollectionVC") as! TeamCollectionViewController
            return viewController.heightForView()

        case "d":
            let storyboard = UIStoryboard(name: "Todo", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
            return viewController.heightForView()
            
        case "m":
            let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingsViewController") as! MeetingsViewController
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
    }
}

extension Person2DetailsViewController: NotesViewControllerDelegate {
    func notesViewController(notesViewController: NotesViewController, didUpdateNotes notes: String) {
        if let personPFObject = personPFObject {
            personPFObject["notes"] = notes
        }
    }
}

extension Person2DetailsViewController: DCPathButtonDelegate {
    func didDismissDCPathButtonItems(_ dcPathButton: DCPathButton!) {
        if !dcPathButton.isDescendant(of: view) {
            configureDCPathButton()
        } else {
            dcPathButton.removeFromSuperview()
            configureDCPathButton()
        }
    }
    
    func pathButton(_ dcPathButton: DCPathButton!, clickItemButtonAt itemButtonIndex: UInt) {
        guard itemButtonIndex != 0 && itemButtonIndex != 1 else {
            ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Sorry, info and team cards may not be manually updated")
            return
        }
        
        let card = Constants.personCards[Int(itemButtonIndex)]
        
        if selectedCards.contains(card) {
            let query = PFQuery(className: "Person")
            if let personPFObject = personPFObject,
                let personId = personPFObject.objectId {
                query.whereKey("objectId", equalTo: personId)
            }
            
            query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                if let posts = posts,
                    let id = card.id {
                    
                    if posts.count > 0 {
                        let post = posts[0]
                        self.selectedCardsString = self.selectedCardsString.replacingOccurrences(of: id, with: "")
                        post["selectedCards"] = self.selectedCardsString
                        post.saveInBackground { (success: Bool, error: Error?) in
                            print("successfully removed person card")
                        }
                    }
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error removing person card, error: \(error?.localizedDescription)")
                    //print("error removing person card")
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
            
        } else {
            let query = PFQuery(className: "Person")
            if let personPFObject = personPFObject,
                let personId = personPFObject.objectId {
                query.whereKey("objectId", equalTo: personId)
            }
            
            query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                if let posts = posts,
                    let id = card.id {
                    
                    if posts.count > 0 {
                        let post = posts[0]
                        self.selectedCardsString = "\(id)\(self.selectedCardsString)"
                        
                        post["selectedCards"] = self.selectedCardsString
                        post.saveInBackground { (success: Bool, error: Error?) in
                            if success {
                                print("successfully saved person card")
                            } else {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving person card, error: \(error?.localizedDescription)")
                                //print("error saving person card")
                            }
                        }
                    } else {
                        let post = PFObject(className: "Person")
                        post["selectedCards"] = self.selectedCardsString
                        post.saveInBackground()
                    }
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving person card, error: \(error?.localizedDescription)")
                    //print("error saving person card")
                }
            }
            
            // Insert new card at the top of the table view
            if isPersonManager {
                if !selectedCards.contains(card) {
                    selectedCards.insert(card, at: 2)
                }
            } else {
                if !selectedCards.contains(card) {
                    selectedCards.insert(card, at: 1)
                }
            }
            tableView.reloadData()
            tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
        }
    }
}
