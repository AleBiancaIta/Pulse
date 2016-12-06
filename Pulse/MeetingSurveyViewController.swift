//
//  MeetingSurveyViewController.swift
//  Pulse
//
//  Created by Itasari on 11/26/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

@objc protocol MeetingSurveyViewControllerDelegate {
    @objc optional func meetingSurveyViewController(_ meetingSurveyViewController: MeetingSurveyViewController, meeting: Meeting, surveyChanged: Bool)
}

class MeetingSurveyViewController: UIViewController {
    
    @IBOutlet weak var teamListTableView: UITableView!
    
    @IBOutlet weak var surveyDescrView: UIView!
    @IBOutlet weak var surveyDescrLabel: UILabel!
    @IBOutlet weak var surveyDescrBackground: UIView!
    
    @IBOutlet weak var survey1Low: UISwitch! // 0
    @IBOutlet weak var survey1Med: UISwitch! // 1
    @IBOutlet weak var survey1High: UISwitch! // 2
    
    @IBOutlet weak var survey2Low: UISwitch!
    @IBOutlet weak var survey2Med: UISwitch!
    @IBOutlet weak var survey2High: UISwitch!
    
    @IBOutlet weak var survey3Low: UISwitch!
    @IBOutlet weak var survey3Med: UISwitch!
    @IBOutlet weak var survey3High: UISwitch!
    
    fileprivate let parseClient = ParseClient.sharedInstance()
    fileprivate var isPersonExpanded: Bool = false
    fileprivate var personRowSelected: Int? = nil
    fileprivate var teamMembers = [PFObject]()
    fileprivate var manager: PFObject!
    fileprivate var person: PFObject!
    fileprivate var managerId: String!
    fileprivate var personId: String!
    
    fileprivate var originalSurveyValue1: Int?
    fileprivate var originalSurveyValue2: Int?
    fileprivate var originalSurveyValue3: Int?
    //fileprivate var originalPerson: PFObject?
    fileprivate var isValue1Changed = false
    fileprivate var isValue2Changed = false
    fileprivate var isValue3Changed = false
    //fileprivate var isPersonChanged = false
    
    var meeting: Meeting!
    var isExistingMeeting: Bool! // False if new meeting, otherwise true
    
    var viewTypes: ViewTypes = .dashboard // Default
    var teamMember: PFObject? // passed from Person page
    
    weak var delegate: MeetingSurveyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellNibs()
        configureRowHeight()

        if isExistingMeeting != nil {
            if isExistingMeeting! {
                loadExistingMeeting()
            } else {
                startNewMeeting()
            }
        }
        
        surveyDescrView.layer.cornerRadius = 5
    }
    
    fileprivate func configureRowHeight() {
        teamListTableView.estimatedRowHeight = 44
        teamListTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    fileprivate func loadExistingMeeting() {
        if let meeting = meeting {
            managerId = meeting.managerId
            personId = meeting.personId
            
            // Fetch Person
            parseClient.fetchPersonFor(personId: personId) { (person: PFObject?, error: Error?) in
                if let error = error {
                    debugPrint("Unable to find person associated with this meeting, error: \(error.localizedDescription)")
                } else {
                    self.person = person
                    
                    /*
                    if let person = person, let firstName = person[ObjectKeys.Person.firstName] as? String, let lastName = person[ObjectKeys.Person.lastName] as? String {
                        self.title = "Meeting with \(firstName) \(lastName)"
                    }*/
                    
                    //self.originalPerson = person
                    self.teamListTableView.reloadData()
                }
            }
            
            // Fetch Survey
            parseClient.fetchSurveyFor(surveyId: meeting.surveyId, isAscending: false, orderBy: ObjectKeys.Survey.updatedAt) { (survey: PFObject?, error: Error?) in
                if let error = error {
                    debugPrint("Unable to find survey associated with survey id \(meeting.surveyId), error: \(error.localizedDescription)")
                } else {
                    if let survey = survey {
                        self.configureSurveySwitches(survey: survey)
                    } else {
                        debugPrint("MeetingSurveyVC fetchSurveyFor returned nil survey")
                    }
                }
            }
        } else {
            debugPrint("meeting is nil")
        }
    }
    
    fileprivate func configureSurveySwitches(survey: PFObject) {
        
        // Reset
        survey1Med.isOn = false
        survey2Med.isOn = false
        survey3Med.isOn = false
        
        if let survey1Value = survey[ObjectKeys.Survey.surveyValueId1] as? Int {
            self.originalSurveyValue1 = survey1Value
            
            if survey1Value == 0 {
                survey1Low.isOn = true
            } else if survey1Value == 1 {
                survey1Med.isOn = true
            } else if survey1Value == 2 {
                survey1High.isOn = true
            }
        }
        
        if let survey2Value = survey[ObjectKeys.Survey.surveyValueId2] as? Int {
            self.originalSurveyValue2 = survey2Value
            
            if survey2Value == 0 {
                survey2Low.isOn = true
            } else if survey2Value == 1 {
                survey2Med.isOn = true
            } else if survey2Value == 2 {
                survey2High.isOn = true
            }
        }
        
        if let survey3Value = survey[ObjectKeys.Survey.surveyValueId3] as? Int {
            self.originalSurveyValue3 = survey3Value
            
            if survey3Value == 0 {
                survey3Low.isOn = true
            } else if survey3Value == 1 {
                survey3Med.isOn = true
            } else if survey3Value == 2 {
                survey3High.isOn = true
            }
        }
    }

    fileprivate func startNewMeeting() {
        parseClient.getCurrentPerson { (manager: PFObject?, error: Error?) in
            if let error = error {
                debugPrint("Failed to fetch current user info, error: \(error.localizedDescription)")
            } else {
                if let manager = manager {
                    self.manager = manager
                    self.fetchTeamMembers(managerId: manager.objectId!)
                } else {
                    debugPrint("MeetingSurveyVC getCurrentPerson returned nil")
                }
            }
        }
        
    }

    fileprivate func fetchTeamMembers(managerId: String) {
        parseClient.fetchTeamMembersFor(managerId: managerId, isAscending1: true, isAscending2: nil, orderBy1: ObjectKeys.Person.lastName, orderBy2: nil, isDeleted: false) { (teams: [PFObject]?, error: Error?) in
            if let error = error {
                debugPrint("Failed to fetch team members with error: \(error.localizedDescription)")
            } else {
                if let teams = teams, teams.count > 0  {
                    self.teamMembers = teams
                    self.teamListTableView.reloadData()
                } else {
                    debugPrint("Fetching team members returned 0 result")
                }
            }
        }
    }
    
    fileprivate func registerCellNibs() {
        teamListTableView.register(UINib(nibName: "MeetingPersonListCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Meeting.meetingPersonListCell)
    }

    func heightForView() -> CGFloat {
        return 350 // Calculate height properly
    }
    
    // MARK: - Actions
    
    @IBAction func onDismissSurveyDescr(_ sender: UITapGestureRecognizer) {
        surveyDescrView.alpha = 0.9
        surveyDescrBackground.alpha = 0.5
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            self.surveyDescrView.alpha = 0.0
            self.surveyDescrBackground.alpha = 0.0
        }, completion: { (Bool) in
            self.surveyDescrView.isHidden = true
            self.surveyDescrBackground.isHidden = true
        })
    }
    
    @IBAction func onSurvey1InfoButton(_ sender: Any) {
        var name = "Team member"
        if let person = person,
            let firstName = person["firstName"] as? String {
            name = firstName
        }
        surveyDescrLabel.text = "Poor: \(name) is currently in an unhappy state\n\nGood: \(name) is okay, but could be doing better\n\nGreat: \(name) feels great!"
        
        surveyDescrLabel.sizeToFit()
        surveyDescrView.sizeToFit()
        
        surveyDescrView.alpha = 0
        surveyDescrBackground.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.surveyDescrView.isHidden = false
            self.surveyDescrBackground.isHidden = false
            self.surveyDescrView.alpha = 0.9
            self.surveyDescrBackground.alpha = 0.5
        }, completion: nil)
    }
    
    @IBAction func onSurvey2InfoButton(_ sender: Any) {
        var name = "Team member"
        if let person = person,
            let firstName = person["firstName"] as? String {
            name = firstName
        }
        surveyDescrLabel.text = "Poor: \(name) is not feeling engaged\n\nGood: \(name) is feeling somewhat engaged\n\nGreat: \(name) is totally engaged!"
        
        surveyDescrLabel.sizeToFit()
        surveyDescrView.sizeToFit()
        
        surveyDescrView.alpha = 0
        surveyDescrBackground.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.surveyDescrView.isHidden = false
            self.surveyDescrBackground.isHidden = false
            self.surveyDescrView.alpha = 0.9
            self.surveyDescrBackground.alpha = 0.5
        }, completion: nil)
    }
    
    @IBAction func onSurvey3InfoButton(_ sender: Any) {
        var name = "Team member"
        if let person = person,
            let firstName = person["firstName"] as? String {
            name = firstName
        }
        surveyDescrLabel.text = "Poor: \(name)'s workload is too heavy or too light\n\nGood: \(name)'s workload is manageable\n\nGreat: \(name)'s workload is just right!"
        
        surveyDescrLabel.sizeToFit()
        surveyDescrView.sizeToFit()
        
        surveyDescrView.alpha = 0
        surveyDescrBackground.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.surveyDescrView.isHidden = false
            self.surveyDescrBackground.isHidden = false
            self.surveyDescrView.alpha = 0.9
            self.surveyDescrBackground.alpha = 0.5
        }, completion: nil)
    }
    
    @IBAction func onSurvey1LowSwitch(_ sender: AnyObject) {
        // survey1Low.isOn = !survey1Low.isOn not working properly
        
        if survey1Low.isOn {
            survey1Med.isOn = false
            survey1High.isOn = false
        }
        
        if let originalSurveyValue1 = originalSurveyValue1 {
            if originalSurveyValue1 == 0 {
                isValue1Changed = false
            } else {
                isValue1Changed = true
            }
        }
    }
    
    @IBAction func onSurvey1MedSwitch(_ sender: AnyObject) {
        if survey1Med.isOn {
            survey1Low.isOn = false
            survey1High.isOn = false
        }
        
        if let originalSurveyValue1 = originalSurveyValue1 {
            if originalSurveyValue1 == 1 {
                isValue1Changed = false
            } else {
                isValue1Changed = true
            }
        }
    }
    
    @IBAction func onSurvey1HighSwitch(_ sender: AnyObject) {
        if survey1High.isOn {
            survey1Low.isOn = false
            survey1Med.isOn = false
        }
        
        if let originalSurveyValue1 = originalSurveyValue1 {
            if originalSurveyValue1 == 2 {
                isValue1Changed = false
            } else {
                isValue1Changed = true
            }
        }
    }
    
    @IBAction func onSurvey2LowSwitch(_ sender: AnyObject) {
        if survey2Low.isOn {
            survey2Med.isOn = false
            survey2High.isOn = false
        }
        
        if let originalSurveyValue2 = originalSurveyValue2 {
            if originalSurveyValue2 == 0 {
                isValue2Changed = false
            } else {
                isValue2Changed = true
            }
        }
    }
    
    @IBAction func onSurvey2MedSwitch(_ sender: AnyObject) {
        if survey2Med.isOn {
            survey2Low.isOn = false
            survey2High.isOn = false
        }
        
        if let originalSurveyValue2 = originalSurveyValue2 {
            if originalSurveyValue2 == 1 {
                isValue2Changed = false
            } else {
                isValue2Changed = true
            }
        }
    }
    
    @IBAction func onSurvey2HighSwitch(_ sender: AnyObject) {
        if survey2High.isOn {
            survey2Low.isOn = false
            survey2Med.isOn = false
        }
        
        if let originalSurveyValue2 = originalSurveyValue2 {
            if originalSurveyValue2 == 2 {
                isValue2Changed = false
            } else {
                isValue2Changed = true
            }
        }
    }
    
    @IBAction func onSurvey3LowSwitch(_ sender: AnyObject) {
        if survey3Low.isOn {
            survey3Med.isOn = false
            survey3High.isOn = false
        }
        
        if let originalSurveyValue3 = originalSurveyValue3 {
            if originalSurveyValue3 == 0 {
                isValue3Changed = false
            } else {
                isValue3Changed = true
            }
        }
    }
    
    @IBAction func onSurvey3MedSwitch(_ sender: AnyObject) {
        if survey3Med.isOn {
            survey3Low.isOn = false
            survey3High.isOn = false
        }
        
        if let originalSurveyValue3 = originalSurveyValue3 {
            if originalSurveyValue3 == 1 {
                isValue3Changed = false
            } else {
                isValue3Changed = true
            }
        }
    }
    
    @IBAction func onSurvey3HighSwitch(_ sender: AnyObject) {
        if survey3High.isOn {
            survey3Low.isOn = false
            survey3Med.isOn = false
        }
        
        if let originalSurveyValue3 = originalSurveyValue3 {
            if originalSurveyValue3 == 2 {
                isValue3Changed = false
            } else {
                isValue3Changed = true
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MeetingSurveyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let isExistingMeeting = isExistingMeeting, isExistingMeeting == true  {
            return 1
        } else {
            // New meeting coming from Person (and have a non-nil personId)
            if viewTypes == .employeeDetail && teamMember != nil {
                return 1
            } else { // New meeting coming from Dashboard
                if isPersonExpanded {
                    return teamMembers.count + 1
                } else {
                    return 1
                }
            }
        }
    }
    
    // if existing meeting, only shows 1 row with the name of person listed (personId != nil), if not, show the list of the team member
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Meeting.meetingPersonListCell, for: indexPath) as! MeetingPersonListCell
            
            if let isExistingMeeting = isExistingMeeting, isExistingMeeting == true  {
                cell.isUserInteractionEnabled = false
                cell.firstRow = false
                if let person = self.person {
                    cell.person = person
                }
            } else {
                // New meeting coming from Person (and have a non-nil personId)
                if viewTypes == .employeeDetail && teamMember != nil {
                    cell.isUserInteractionEnabled = false
                    cell.firstRow = false
                    cell.selectedPerson = teamMember
                } else { // New meeting coming from Dashboard
                    //cell.isUserInteractionEnabled = isPersonExpanded ? false : true
                    cell.isUserInteractionEnabled = true
                    cell.firstRow = true // only applies to new user with not yet selected team member (show carrot or not)
                    if let selectedPerson = personRowSelected {
                        cell.selectedPerson = teamMembers[selectedPerson]
                    }
                }
            }
            return cell
        default: // should only get here if teamMember == nil
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Meeting.meetingPersonListCell, for: indexPath) as! MeetingPersonListCell
            cell.firstRow = false
            cell.isUserInteractionEnabled = true
            cell.person = teamMembers[indexPath.row - 1]
            
            if let selectedRow = personRowSelected, selectedRow == (indexPath.row - 1) {
                cell.highlightBackground = true
            } else {
                cell.highlightBackground = false
            }
            
            return cell
        }
    
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && !(isExistingMeeting!) && (teamMember == nil) {
            if isPersonExpanded { // need to collapse
                if indexPath.row > 0 {
                    personRowSelected = indexPath.row - 1
                }
                isPersonExpanded = !isPersonExpanded
            } else { // need to expand
                isPersonExpanded = !isPersonExpanded
            }
            teamListTableView.reloadData()
        } 
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension MeetingSurveyViewController: MeetingDetailsViewControllerDelegate {
    func meetingDetailsViewController(_ meetingDetailsViewController: MeetingDetailsViewController, onSave: Bool) {
        if onSave {
            if !isExistingMeeting { // new meeting
                if validateNewMeeting() {
                    let person = self.teamMember != nil ? self.teamMember! : teamMembers[personRowSelected!]
                    let personId = person.objectId!
                    let companyId = person[ObjectKeys.Person.companyId] as! String
                    
                    saveNewSurvey(personId: personId, companyId: companyId) { (success: Bool, survey: PFObject?, error: Error?) in
                        if success {
                            print("survey saved successfully")
                            
                            let managerId = self.manager.objectId!
                            let dictionary: [String: Any] =
                                [ObjectKeys.Meeting.personId: personId,
                                 ObjectKeys.Meeting.managerId: managerId,
                                 ObjectKeys.Meeting.surveyId: survey?.objectId! as Any,
                                 ObjectKeys.Meeting.meetingDate: Date()]
                            
                            self.meeting = Meeting(dictionary: dictionary)
                            self.delegate?.meetingSurveyViewController?(self, meeting: self.meeting, surveyChanged: true)
                        } else {
                            if let error = error {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to save new survey with error: \(error.localizedDescription)")
                            } else {
                                self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to save new survey with error")
                            }
                        }
                    }
                } else {
                    ABIShowDropDownAlert(type: AlertTypes.alert, title: "Alert!", message: "Please complete the required fields")
                }
            } else { // existing meeting
                if (isValue1Changed || isValue2Changed || isValue3Changed) {
                    parseClient.fetchSurveyFor(surveyId: meeting.surveyId, isAscending: false, orderBy: ObjectKeys.Survey.updatedAt) { (survey: PFObject?, error: Error?) in
                        // update survey values
                        if let error = error {
                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to fetch survey, error: \(error.localizedDescription)")
                            //debugPrint("Failed to fetch survey, error: \(error.localizedDescription)")
                        } else {
                            if let survey = survey {
                                survey[ObjectKeys.Survey.surveyValueId1] = (self.survey1Low.isOn ? 0 : (self.survey1High.isOn ? 2 : 1))
                                survey[ObjectKeys.Survey.surveyValueId2] = (self.survey2Low.isOn ? 0 : (self.survey2High.isOn ? 2 : 1))
                                survey[ObjectKeys.Survey.surveyValueId3] = (self.survey3Low.isOn ? 0 : (self.survey3High.isOn ? 2 : 1))
                                survey.saveInBackground { (success: Bool, error: Error?) in
                                    if success {
                                        self.delegate?.meetingSurveyViewController?(self, meeting: self.meeting, surveyChanged: true)
                                    } else {
                                        if let error = error {
                                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to save survey, error: \(error.localizedDescription)")
                                        } else {
                                            self.ABIShowDropDownAlert(type: AlertTypes.failure, title: "Error!", message: "Failed to save survey")
                                        }
                                    }
                                }
                            } else {
                                debugPrint("Fetch survey returned nil")
                            }
                        }
                    }
                } else {
                    delegate?.meetingSurveyViewController?(self, meeting: self.meeting, surveyChanged: false)
                    debugPrint("no changed in survey values")
                }
            }
        }
    }
    
    fileprivate func validateNewMeeting() -> Bool {
        return ((personRowSelected != nil) || (teamMember != nil)) && (survey1Low.isOn || survey1Med.isOn || survey1High.isOn) && (survey2Low.isOn || survey2Med.isOn || survey2High.isOn) && (survey3Low.isOn || survey3Med.isOn || survey3High.isOn)
    }
    
    fileprivate func saveNewSurvey(personId: String, companyId: String, completion: @escaping (Bool, PFObject?, Error?)->()) {
        let survey = PFObject(className: "Survey")
        survey[ObjectKeys.Survey.surveyDesc1] = "happiness"
        survey[ObjectKeys.Survey.surveyValueId1] = (self.survey1Low.isOn ? 0 : (self.survey1High.isOn ? 2 : 1))
        survey[ObjectKeys.Survey.surveyDesc2] = "engagement"
        survey[ObjectKeys.Survey.surveyValueId2] = (self.survey2Low.isOn ? 0 : (self.survey2High.isOn ? 2 : 1))
        survey[ObjectKeys.Survey.surveyDesc3] = "workload"
        survey[ObjectKeys.Survey.surveyValueId3] = (self.survey3Low.isOn ? 0 : (self.survey3High.isOn ? 2 : 1))
        survey[ObjectKeys.Survey.meetingDate] = Date()
        survey[ObjectKeys.Survey.personId] = personId
        survey[ObjectKeys.Survey.companyId] = companyId
        survey.saveInBackground { (success: Bool, error: Error?) in
            if let error = error {
                completion(false, nil, error)
            } else {
                completion(true, survey, nil)
            }
        }
    }
}
