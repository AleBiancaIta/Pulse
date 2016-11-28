//
//  MeetingSurveyViewController.swift
//  Pulse
//
//  Created by Itasari on 11/26/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class MeetingSurveyViewController: UIViewController {
    
    @IBOutlet weak var teamListTableView: UITableView!
    
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
    
    var meeting: Meeting!
    var isExistingMeeting: Bool! // False if new meeting, otherwise true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellNibs()

        if isExistingMeeting != nil {
            if isExistingMeeting! {
                loadExistingMeeting()
            } else {
                startNewMeeting()
            }
        }
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
            if survey1Value == 0 {
                survey1Low.isOn = true
            } else if survey1Value == 1 {
                survey1Med.isOn = true
            } else if survey1Value == 2 {
                survey1High.isOn = true
            }
        }
        
        if let survey2Value = survey[ObjectKeys.Survey.surveyValueId2] as? Int {
            if survey2Value == 0 {
                survey2Low.isOn = true
            } else if survey2Value == 1 {
                survey2Med.isOn = true
            } else if survey2Value == 2 {
                survey2High.isOn = true
            }
        }
        
        if let survey3Value = survey[ObjectKeys.Survey.surveyValueId3] as? Int {
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
        
    }

    fileprivate func registerCellNibs() {
        teamListTableView.register(UINib(nibName: "MeetingPersonListCell", bundle: nil), forCellReuseIdentifier: CellReuseIdentifier.Meeting.meetingPersonListCell)
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

    func heightForView() -> CGFloat {
        return 300 // TODO: Calculate height properly
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    
    @IBAction func onSurvey1LowSwitch(_ sender: AnyObject) {
        // survey1Low.isOn = !survey1Low.isOn not working properly
        
        if survey1Low.isOn {
            survey1Med.isOn = false
            survey1High.isOn = false
        }
    }
    
    @IBAction func onSurvey1MedSwitch(_ sender: AnyObject) {
        if survey1Med.isOn {
            survey1Low.isOn = false
            survey1High.isOn = false
        }
    }
    
    @IBAction func onSurvey1HighSwitch(_ sender: AnyObject) {
        if survey1High.isOn {
            survey1Low.isOn = false
            survey1Med.isOn = false
        }
    }
    
    @IBAction func onSurvey2LowSwitch(_ sender: AnyObject) {
        if survey2Low.isOn {
            survey2Med.isOn = false
            survey2High.isOn = false
        }
    }
    
    @IBAction func onSurvey2MedSwitch(_ sender: AnyObject) {
        if survey2Med.isOn {
            survey2Low.isOn = false
            survey2High.isOn = false
        }
    }
    
    @IBAction func onSurvey2HighSwitch(_ sender: AnyObject) {
        if survey2High.isOn {
            survey2Low.isOn = false
            survey2Med.isOn = false
        }
    }
    
    @IBAction func onSurvey3LowSwitch(_ sender: AnyObject) {
        if survey3Low.isOn {
            survey3Med.isOn = false
            survey3High.isOn = false
        }
    }
    
    @IBAction func onSurvey3MedSwitch(_ sender: AnyObject) {
        if survey3Med.isOn {
            survey3Low.isOn = false
            survey3High.isOn = false
        }
    }
    
    @IBAction func onSurvey3HighSwitch(_ sender: AnyObject) {
        if survey3High.isOn {
            survey3Low.isOn = false
            survey3Med.isOn = false
        }
    }
    

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MeetingSurveyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPersonExpanded {
            return teamMembers.count + 1
        } else {
            return 1
        }
        
    }
    
    // if existing meeting, only shows 1 row with the name of person listed (personId != nil), if not, show the list of the team member
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.Meeting.meetingPersonListCell, for: indexPath) as! MeetingPersonListCell
            cell.firstRow = true
            cell.isUserInteractionEnabled = isPersonExpanded ? false : true
            
            if let selectedPerson = personRowSelected {
                cell.selectedPerson = teamMembers[selectedPerson]
            }
            
            return cell
        default:
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
        
        if indexPath.section == 1 {
            if isPersonExpanded { // need to collapse
                personRowSelected = indexPath.row - 1
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
