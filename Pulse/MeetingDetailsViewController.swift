//
//  MeetingDetailsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import DCPathButton
import Parse
import UIKit

@objc protocol MeetingDetailsViewControllerDelegate {
   @objc optional func meetingDetailsViewController(_ meetingDetailsViewController: MeetingDetailsViewController, onSave: Bool)
}

class MeetingDetailsViewController: UIViewController {
   
   @IBOutlet weak var tableView: UITableView!
   
   var dcPathButton:DCPathButton!
   
   var selectedCardsString: String = ""
   var selectedCards: [Card] = [Constants.meetingCards[0]] // Always include survey card
   
   var meeting: Meeting!
   var isExistingMeeting = true // False if new meeting, otherwise true
   var viewTypes: ViewTypes = .dashboard // Default
   var teamMember: PFObject? // Passed on from Person page
   
   fileprivate let parseClient = ParseClient.sharedInstance()
   weak var delegate: MeetingDetailsViewControllerDelegate?
   weak var delegate2: MeetingDetailsViewControllerDelegate?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      if !isExistingMeeting {
         title = "New Meeting"
      } else {
         let formatter = DateFormatter()
         formatter.dateStyle = .medium
         let meetingDate = formatter.string(from: meeting.meetingDate)
         title = "\(meetingDate)"
      }
      
      UIExtensions.gradientBackgroundFor(view: view)
      navigationController?.navigationBar.barStyle = .blackTranslucent
      
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButton(_:)))
      
      tableView.dataSource = self
      tableView.delegate = self
      tableView.estimatedRowHeight = 100
      tableView.rowHeight = UITableViewAutomaticDimension
      
      tableView.register(UINib(nibName: "CustomTextCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
      
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      
      loadSelectedCards()
      
      // Hide card functionality if not existing meeting
      if isExistingMeeting {
         configureDCPathButton()
      }
   }
   
   func keyboardWillShow(notification: NSNotification) {
      if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
         //view.frame.size.height = UIScreen.main.bounds.height - keyboardSize.height - 64
         if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
         }
         view.frame.origin.y -= keyboardSize.height - 64
      }
   }
   
   func keyboardWillHide(notification: NSNotification) {
      view.frame.size.height = UIScreen.main.bounds.height - 64
      view.frame.origin.y = 64
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
      dcPathButton.bloomRadius = 70
      
      var surveyImage = UIImage.resizeImageWithSize(image: UIImage(named: "Smiley")!, newSize: CGSize(width: size, height: size))
      surveyImage = UIImage.recolorImageWithColor(image: surveyImage, color: color)
      let surveyHighlightedImage = UIImage.recolorImageWithColor(image: surveyImage, color: highlightColor)
      let surveySelectedImage = selectedCards.contains(Constants.meetingCards[0]) ? surveyHighlightedImage : surveyImage
      let surveyButton = DCPathItemButton(image: surveySelectedImage, highlightedImage: surveyHighlightedImage, backgroundImage: surveyImage, backgroundHighlightedImage: surveyHighlightedImage)
      
      var toDoImage = UIImage.resizeImageWithSize(image: UIImage(named: "Todo")!, newSize: CGSize(width: size, height: size))
      toDoImage = UIImage.recolorImageWithColor(image: toDoImage, color: color)
      let toDoHighlightedImage = UIImage.recolorImageWithColor(image: toDoImage, color: highlightColor)
      let toDoSelectedImage = selectedCards.contains(Constants.meetingCards[1]) ? toDoHighlightedImage : toDoImage
      let toDoButton = DCPathItemButton(image: toDoSelectedImage, highlightedImage: toDoHighlightedImage, backgroundImage: toDoImage, backgroundHighlightedImage: toDoHighlightedImage)
      
      var notesImage = UIImage.resizeImageWithSize(image: UIImage(named: "DoublePaper")!, newSize: CGSize(width: size, height: size))
      notesImage = UIImage.recolorImageWithColor(image: notesImage, color: color)
      let notesHighlightedImage = UIImage.recolorImageWithColor(image: notesImage, color: highlightColor)
      let notesSelectedImage = selectedCards.contains(Constants.meetingCards[2]) ? notesHighlightedImage : notesImage
      let notesButton = DCPathItemButton(image: notesSelectedImage, highlightedImage: notesHighlightedImage, backgroundImage: notesImage, backgroundHighlightedImage: notesHighlightedImage)
      
      dcPathButton.addPathItems([surveyButton, toDoButton, notesButton])
      dcPathButton.frame = CGRect(x: view.center.x - size/2, y: UIScreen.main.bounds.height - 64 - 8 - size, width: size, height: size)
      view.addSubview(dcPathButton)
   }
   
   func loadSelectedCards() {
      
      // Existing meeting
      if nil != meeting {
         if let selectedCardsString = meeting.selectedCards {
            self.selectedCardsString = selectedCardsString
            for c in (meeting.selectedCards?.characters)! {
               switch c {
               case "d":
                  if !self.selectedCards.contains(Constants.meetingCards[1]) {
                     selectedCards.append(Constants.meetingCards[1])
                  }
               case "n":
                  if !self.selectedCards.contains(Constants.meetingCards[2]) {
                     selectedCards.append(Constants.meetingCards[2])
                  }
               default:
                  break
               }
            }
         }
      }
   }
   
   func onSaveButton(_ sender: UIBarButtonItem) {
      delegate?.meetingDetailsViewController?(self, onSave: true)
      delegate2?.meetingDetailsViewController?(self, onSave: true)
      configureDCPathButton()
   }
}

// MARK: - UITableViewDataSource

extension MeetingDetailsViewController: UITableViewDataSource {
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      switch selectedCards[indexPath.section].id! {
      case "s":
         let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyContainerCell", for: indexPath)
         cell.layer.cornerRadius = 5
         cell.selectionStyle = .none
         
         if cell.contentView.subviews == [] {
            let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardID.meetingSurveyVC) as! MeetingSurveyViewController
            viewController.meeting = meeting
            viewController.isExistingMeeting = isExistingMeeting
            
            if self.viewTypes == .employeeDetail && self.teamMember != nil {
               viewController.viewTypes = self.viewTypes
               viewController.teamMember = self.teamMember!
            }
            
            viewController.delegate = self
            self.delegate = viewController
            
            viewController.willMove(toParentViewController: self)
            viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
            cell.contentView.addSubview(viewController.view)
            self.addChildViewController(viewController)
            viewController.didMove(toParentViewController: self)
         }
         return cell
         
      case "d":
         let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoContainerCell", for: indexPath)
         cell.layer.cornerRadius = 5
         cell.selectionStyle = .none
         
         if cell.contentView.subviews == [] {
            let storyboard = UIStoryboard(name: "Todo", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TodoVC") as! TodoViewController
            viewController.currentMeeting = meeting
            viewController.viewTypes = .meeting
            
            viewController.willMove(toParentViewController: self)
            viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
            cell.contentView.addSubview(viewController.view)
            self.addChildViewController(viewController)
            viewController.didMove(toParentViewController: self)
         }
         
         return cell
         
      case "n":
         let cell = tableView.dequeueReusableCell(withIdentifier: "NotesContainerCell", for: indexPath)
         cell.layer.cornerRadius = 5
         cell.selectionStyle = .none
         cell.backgroundColor = UIColor.clear
         
         if cell.contentView.subviews == [] {
            let storyboard = UIStoryboard(name: "Notes", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
            viewController.delegate = self
            self.delegate2 = viewController
            viewController.notes = meeting.notes
            
            viewController.willMove(toParentViewController: self)
            viewController.view.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.heightForView())
            cell.contentView.addSubview(viewController.view)
            self.addChildViewController(viewController)
            viewController.didMove(toParentViewController: self)
         }
         
         return cell
         
      default: // This shouldn't actually be reached
         let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell", for: indexPath) as! CustomTextCell
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

extension MeetingDetailsViewController: UITableViewDelegate {
   
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
      case "s":
         let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
         let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardID.meetingSurveyVC) as! MeetingSurveyViewController
         return viewController.heightForView()
         
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
   }
}

extension MeetingDetailsViewController: NotesViewControllerDelegate {
   func notesViewController(notesViewController: NotesViewController, didUpdateNotes notes: String) {
      meeting.notes = notes
   }
}

extension MeetingDetailsViewController: MeetingSurveyViewControllerDelegate {

    func meetingSurveyViewController(_ meetingSurveyViewController: MeetingSurveyViewController, meeting: Meeting, surveyChanged: Bool) {
        if surveyChanged {
            if isExistingMeeting {
                saveExistingMeeting(meeting: self.meeting)
            } else {
                saveNewMeeting(meeting: meeting)
            }
        } else {
            // save notes in case it's changed
            saveExistingMeeting(meeting: self.meeting)
        }
    }
    
   fileprivate func saveExistingMeeting(meeting: Meeting) {
      parseClient.fetchMeetingFor(meetingId: meeting.objectId!) { (meeting: PFObject?, error: Error?) in
         if let meeting = meeting {
            meeting[ObjectKeys.Meeting.notes] = self.meeting.notes
            meeting[ObjectKeys.Meeting.selectedCards] = self.selectedCardsString
            meeting.saveInBackground { (success: Bool, error: Error?) in
               if success {
                  self.isExistingMeeting = true
                  self.tableView.reloadData()
                  self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success!", message: "Meeting saved")
               } else {
                  if let error = error {
                     self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to saved meeting, error: \(error.localizedDescription)")
                  }
               }
            }
         } else {
            debugPrint("Failed to fetch meeting, error: \(error?.localizedDescription)")
            if let error = error {
               self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to saved meeting, error: \(error.localizedDescription)")
            }
         }
      }
   }
   
   fileprivate func saveNewMeeting(meeting: Meeting) {
      meeting.selectedCards = self.selectedCardsString
      Meeting.saveMeetingToParse(meeting: meeting) { (success: Bool, error: Error?) in
         if success {
            self.parseClient.fetchMeetingFor(personId: meeting.personId, managerId: meeting.managerId, surveyId: meeting.surveyId, isDeleted: false) { (meetingObject: PFObject?, error: Error?) in
               if let error = error {
                  debugPrint("Failed to fetch newly saved meeting, error: \(error.localizedDescription)")
                  self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to saved meeting, error: \(error.localizedDescription)")
               } else {
                  self.meeting = meeting
                  self.meeting.objectId = meetingObject?.objectId
                  self.isExistingMeeting = true
                  self.tableView.reloadData()
                  self.ABIShowDropDownAlert(type: AlertTypes.success, title: "Success!", message: "Meeting saved")
               }
            }
         } else {
            if let error = error {
               self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Unable to saved meeting, error: \(error.localizedDescription)")
            }
         }
      }
   }
}

extension MeetingDetailsViewController: DCPathButtonDelegate {
   func didDismissDCPathButtonItems(_ dcPathButton: DCPathButton!) {
      if !dcPathButton.isDescendant(of: view) {
         configureDCPathButton()
      } else {
         dcPathButton.removeFromSuperview()
         configureDCPathButton()
      }
   }
   
   func pathButton(_ dcPathButton: DCPathButton!, clickItemButtonAt itemButtonIndex: UInt) {
      guard itemButtonIndex != 0 else {
         //alertController.message = "Sorry, survey card may not be manually updated"
         //present(alertController, animated: true)
         ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Sorry, survey card may not be manually updated")
         return
      }
      
      let card = Constants.meetingCards[Int(itemButtonIndex)]
      
      if selectedCards.contains(card) {
         let query = PFQuery(className: "Meetings")
         if let meetingId = meeting.objectId {
            query.whereKey("objectId", equalTo: meetingId)
         }
         
         query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts,
               let id = card.id {
               
               if posts.count > 0 {
                  let post = posts[0]
                  self.selectedCardsString = self.selectedCardsString.replacingOccurrences(of: id, with: "")
                  post["selectedCards"] = self.selectedCardsString
                  post.saveInBackground { (success: Bool, error: Error?) in
                     print("successfully removed meeting card")
                  }
               }
            } else {
               print("error removing meeting card")
            }
         }
         
         // Remove card from table view
         for (index, meetingCard) in selectedCards.enumerated() {
            if meetingCard.id == card.id {
               selectedCards.remove(at: index)
            }
         }
         tableView.reloadData()
         tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
         
      } else {
         let query = PFQuery(className: "Meetings")
         if let meetingId = meeting.objectId {
            query.whereKey("objectId", equalTo: meetingId)
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
                        print("successfully saved meeting cards")
                     } else {
                        print("error saving meeting cards")
                     }
                  }
               } else {
                  let post = PFObject(className: "Meetings")
                  post["selectedCards"] = self.selectedCardsString
                  post.saveInBackground()
               }
            } else {
               print("error saving meeting cards")
            }
         }
         
         // Insert new card at the top of the table view
         if !selectedCards.contains(card) {
            selectedCards.insert(card, at: 1)
         }
         tableView.reloadData()
         tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
      }
   }
}
