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
    
    var selectedCardsString: String = ""
//    var selectedCardsString: String = "dm" // Default cards (To Do, Meetings)
    var selectedCards: [Card] = [Constants.personCards[0]] // Always include info card
    
    var personPFObject: PFObject?
	var personInfoViewController: PersonDetailsViewController!
    var personManagerId: String?
    var userPersonId: String?
    
    // For keyboard display
    var toDoIndexPath: IndexPath?
    var notesIndexPath: IndexPath?
    
    var isPersonManager: Bool = false
    
    // Card View Controllers
    var infoViewController: PersonDetailsViewController?
    var teamViewController: TeamCollectionViewController?
    var graphViewController: LineGraphViewController?
    var toDoViewController: TodoViewController?
    var meetingsViewController: MeetingsViewController?
    var notesViewController: NotesViewController?
    
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
        tableView.register(UINib(nibName: "CardManagementCell", bundle: nil), forCellReuseIdentifier: "AddCardCell")
        
		initPersonInfo()
        //configureDCPathButton()
        
        tableView.keyboardDismissMode = .onDrag
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
            
            // Only need to move keyboard if bottom fields are being edited
            // Currently, the only cards that activate keyboard are ToDo and Notes
            // Since Info is always the top, no need to move view
            if let toDoIndexPath = toDoIndexPath {
                let rectInSuperview = tableView.convert(tableView.rectForRow(at: toDoIndexPath), to: tableView.superview)
                if rectInSuperview.origin.y > keyboardSize.height {
                    if view.frame.origin.y != 0 {
                        view.frame.origin.y = 0
                    }
                    view.frame.origin.y -= keyboardSize.height - 64 - 44
                } else if toDoIndexPath.section == selectedCards.count - 1 {
                    view.frame.origin.y -= keyboardSize.height - 44
                }
            }
            if let notesIndexPath = notesIndexPath {
                let rectInSuperview = tableView.convert(tableView.rectForRow(at: notesIndexPath), to: tableView.superview)
                if rectInSuperview.origin.y > keyboardSize.height {
                    if view.frame.origin.y != 0 {
                        view.frame.origin.y = 0
                    }
                    view.frame.origin.y -= keyboardSize.height - 64 - 44
                }
            }
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

	func initPersonInfo() {

		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onRightBarButtonTap(_:)))

		let storyboard = UIStoryboard(name: "Person", bundle: nil)
		personInfoViewController = storyboard.instantiateViewController(withIdentifier: "PersonDetailsViewController") as! PersonDetailsViewController
		personInfoViewController.personPFObject = personPFObject
		personInfoViewController.personInfoParentViewController = self
	}

	func onRightBarButtonTap(_ sender: UIBarButtonItem) {
        if let notesViewController = notesViewController,
            let title = navigationItem.rightBarButtonItem?.title {
            //notesViewController.notesTextView.isUserInteractionEnabled = title == "Edit"
            notesViewController.draftLabel.isHidden = title != "Edit"
        }
        
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
            title = firstName != lastName ? "\(firstName) \(lastName)" : firstName
            
            // Hide customizable modules if user is not this person's manager
            if let managerId = personPFObject["managerId"] as? String {
                parseClient.getCurrentPerson { (person: PFObject?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.personManagerId = managerId
                        if let selectedCardsString = personPFObject[ObjectKeys.Person.selectedCards] as? String {
                            self.selectedCardsString = selectedCardsString
                        }
                        if let person = person, managerId != person.objectId {
                            self.userPersonId = person.objectId
                            self.selectedCardsString = self.selectedCardsString.replacingOccurrences(of: "d", with: "")
                            self.selectedCardsString = self.selectedCardsString.replacingOccurrences(of: "m", with: "")
                            self.selectedCardsString = self.selectedCardsString.replacingOccurrences(of: "n", with: "")
                        }
                        
                        for c in self.selectedCardsString.characters {
                            switch c {
                            case "g":
                                if !self.selectedCards.contains(Constants.personCards[2]) {
                                    self.selectedCards.append(Constants.personCards[2])
                                }
                            case "d":
                                if !self.selectedCards.contains(Constants.personCards[3]) {
                                    self.selectedCards.append(Constants.personCards[3])
                                }
                            case "m":
                                if !self.selectedCards.contains(Constants.personCards[4]) {
                                    self.selectedCards.append(Constants.personCards[4])
                                }
                            case "n":
                                if !self.selectedCards.contains(Constants.personCards[5]) {
                                    self.selectedCards.append(Constants.personCards[5])
                                }
                            default:
                                break
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc fileprivate func convertCardsToString() -> String {
        var selectedCardsString = ""
        for meetingCard in selectedCards {
            selectedCardsString += meetingCard.id!
        }
        return selectedCardsString
    }
    
    func onManageCards() {
        let storyboard = UIStoryboard(name: "Person2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PersonDetailsSelectionViewController") as! PersonDetailsSelectionViewController
        viewController.delegate = self
        viewController.selectedCards = selectedCards
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func onLongPress(_ sender: UILongPressGestureRecognizer) {
        tableView.isEditing = true
        // if sender.state == .began
        // else if sender.state == .end
    }
    
    deinit {
        debugPrint("Person2DetailsVC deinitialized")
    }
}

extension Person2DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == selectedCards.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardCell", for: indexPath) as! CardManagementCell
            cell.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.addButton.tintColor = UIColor.lightGray
            cell.addButton.isEnabled = false
            cell.manageLabel.textColor = UIColor.lightGray
            cell.manageLabel.text = "Save team member to manage modules"
            
            if let personPFObject = personPFObject,
                let managerId = personPFObject["managerId"] as? String {
                parseClient.getCurrentPerson { (person: PFObject?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.personManagerId = managerId
                        if let person = person, managerId != person.objectId {
                            self.userPersonId = person.objectId
                            cell.addButton.tintColor = UIColor.lightGray
                            cell.addButton.isEnabled = false
                            cell.manageLabel.textColor = UIColor.lightGray
                            cell.manageLabel.text = "Cannot manage modules for this team member"
                        }
                    }
                }
            }
            
            if personPFObject != nil { // Manage Cards
                cell.addButton.tintColor = UIColor.pulseAccentColor()
                cell.addButton.isEnabled = true
                cell.manageLabel.textColor = UIColor.pulseAccentColor()
                cell.manageLabel.text = "Manage Modules"
                cell.addButton.addTarget(self, action: #selector(onManageCards), for: .touchUpInside)
            }
            
            return cell
            
        } else { // The actual cards
            switch selectedCards[indexPath.section].id! {
			case "i":
                if infoViewController == nil {
                    personInfoViewController.willMove(toParentViewController: self)
                    personInfoViewController.view.frame = CGRect(x: 0, y: 0, width: personInfoViewController.view.frame.size.width, height: personInfoViewController.heightForView())
                    infoViewController = personInfoViewController
                }
                
				let cell = tableView.dequeueReusableCell(withIdentifier: "InfoContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                
                if let infoViewController = infoViewController {
                    if !cell.contentView.subviews.contains(infoViewController.view) {
                        cell.contentView.addSubview(infoViewController.view)
                        self.addChildViewController(infoViewController)
                        infoViewController.didMove(toParentViewController: self)
                    }
                }
                
				return cell
                
            case "t":
                if teamViewController == nil {
                    let storyboard = UIStoryboard(name: "Team", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "TeamCollectionVC") as! TeamCollectionViewController
                    viewController.person = personPFObject
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    teamViewController = viewController
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                cell.backgroundColor = UIColor.clear
                
                if let teamViewController = teamViewController {
                    if !cell.contentView.subviews.contains(teamViewController.view) {
                        cell.contentView.addSubview(teamViewController.view)
                        self.addChildViewController(teamViewController)
                        teamViewController.didMove(toParentViewController: self)
                    }
                }
                
                return cell
                
            case "g":
                if graphViewController == nil {
                    let storyboard = UIStoryboard(name: "Graph", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "LineGraphViewController") as! LineGraphViewController
                    viewController.personPFObject = personPFObject
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width - 16, height: viewController.heightForView())
                    graphViewController = viewController
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "GraphContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                cell.backgroundColor = UIColor.clear
                cell.showsReorderControl = tableView.isEditing
                
                if let graphViewController = graphViewController {
                    if !cell.contentView.subviews.contains(graphViewController.view) {
                        cell.contentView.addSubview(graphViewController.view)
                        self.addChildViewController(graphViewController)
                        graphViewController.didMove(toParentViewController: self)
                    }
                }
                
                return cell

            case "d":
                toDoIndexPath = indexPath // For keyboard display
                
                if toDoViewController == nil {
                    let storyboard = UIStoryboard(name: "Todo", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
                    viewController.currentTeamPerson = personPFObject
                    viewController.viewTypes = .employeeDetail
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    toDoViewController = viewController
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                cell.showsReorderControl = tableView.isEditing
                
                if let toDoViewController = toDoViewController {
                    if !cell.contentView.subviews.contains(toDoViewController.view) {
                        cell.contentView.addSubview(toDoViewController.view)
                        self.addChildViewController(toDoViewController)
                        toDoViewController.didMove(toParentViewController: self)
                    }
                }
                
                return cell
                
            case "m":
                if meetingsViewController == nil {
                    let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "MeetingsViewController") as! MeetingsViewController
                    if let personPFObject = personPFObject {
                        viewController.personId = personPFObject.objectId
                    }
                    viewController.viewTypes = .employeeDetail
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width - 16, height: viewController.heightForView())
                    meetingsViewController = viewController
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingsContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                cell.showsReorderControl = tableView.isEditing
                cell.backgroundColor = UIColor.clear
                
                if let meetingsViewController = meetingsViewController {
                    if !cell.contentView.subviews.contains(meetingsViewController.view) {
                        cell.contentView.addSubview(meetingsViewController.view)
                        self.addChildViewController(meetingsViewController)
                        meetingsViewController.didMove(toParentViewController: self)
                    }
                }
                
                return cell
                
            case "n":
                notesIndexPath = indexPath // For keyboard display
                
                if notesViewController == nil {
                    let storyboard = UIStoryboard(name: "Notes", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
                    viewController.delegate = self
                    if let personPFObject = personPFObject,
                        let notes = personPFObject["notes"] as? String {
                        viewController.notes = notes
                    }
                    viewController.willMove(toParentViewController: self)
                    viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
                    notesViewController = viewController
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotesContainerCell", for: indexPath)
                cell.selectionStyle = .none
                cell.layer.cornerRadius = 5
                cell.backgroundColor = UIColor.clear
                cell.showsReorderControl = tableView.isEditing
                
                if let notesViewController = notesViewController {
                    if !cell.contentView.subviews.contains(notesViewController.view) {
                        cell.contentView.addSubview(notesViewController.view)
                        self.addChildViewController(notesViewController)
                        notesViewController.didMove(toParentViewController: self)
                    }
                }
                
                return cell
                
            default: // This shouldn't actually be reached
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! CustomTextCell
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = selectedCards[sourceIndexPath.section] as Card
        selectedCards.remove(at: sourceIndexPath.section)
        selectedCards.insert(itemToMove, at: destinationIndexPath.section)
        
        selectedCardsString = convertCardsToString()
        
        tableView.isEditing = false
        tableView.reloadData()
        
        let query = PFQuery(className: "Person")
        if let personPFObject = personPFObject,
            let personId = personPFObject.objectId {
            query.whereKey("objectId", equalTo: personId)
        }
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                let post = posts[0]
                post["selectedCards"] = self.selectedCardsString
                post.saveInBackground { (success: Bool, error: Error?) in
                    if success {
                        print("successfully saved re-ordered person cards")
                    } else {
                        if let error = error {
                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving re-ordered person cards, error: \(error.localizedDescription)")
                        } else {
                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving re-ordered person cards")
                        }
                    }
                }
            } else {
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving re-ordered person cards, error: \(error.localizedDescription)")
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving re-ordered person cards")
                }
            }
        }
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
            
        case "g":
            let storyboard = UIStoryboard(name: "Graph", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LineGraphViewController") as! LineGraphViewController
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
        
        if indexPath.section == selectedCards.count && personPFObject != nil && personManagerId == userPersonId {
            onManageCards()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || indexPath.section == selectedCards.count ||
            (indexPath.section == 1 && selectedCards[1].id == "t") {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 0 || proposedDestinationIndexPath.section == selectedCards.count ||
            (proposedDestinationIndexPath.section == 1 && selectedCards[1].id == "t") {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
}

// MARK: - PersonDetailsSelectionViewControllerDelegate

extension Person2DetailsViewController: PersonDetailsSelectionViewControllerDelegate {
    func personDetailsSelectionViewController(personDetailsSelectionViewController: PersonDetailsSelectionViewController, didDismissSelector _: Bool) {
        tableView.reloadData()
    }
    
    func personDetailsSelectionViewController(personDetailsSelectionViewController: PersonDetailsSelectionViewController, didAddCard card: Card) {
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
                            if let error = error {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving person card, error: \(error.localizedDescription)")
                            } else {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving person card")
                            }
                        }
                    }
                } else {
                    let post = PFObject(className: "Person")
                    post["selectedCards"] = self.selectedCardsString
                    post.saveInBackground()
                }
            } else {
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving person card, error: \(error.localizedDescription)")
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error saving person card")
                }
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
    
    func personDetailsSelectionViewController(personDetailsSelectionViewController: PersonDetailsSelectionViewController, didRemoveCard card: Card) {
        
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
                        //print("successfully removed person card")
                    }
                }
            } else {
                if let error = error {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error removing person card, error: \(error.localizedDescription)")
                } else {
                    self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Error removing person card")
                }
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

