//
//  Constants.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Foundation

class Constants: NSObject {

    static let dashboardCards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "g", "name": "Pulse Chart", "card_type": "pulse_graph", "descr": "See, at a glance, the survey results for your company from the past 60 days", "imageName": "PulseGraph"],
        ["id" : "d", "name": "Follow Up Items", "card_type": "to_do", "descr": "Stay organized with this summary of your To Do list items", "imageName": "Todo"],
        ["id" : "t", "name": "Team Members", "card_type": "team", "descr": "A preview of your team members, including their most recent survey input", "imageName": "MyTeamDark"],
        ["id" : "m", "name": "Recent Meetings", "card_type": "meetings", "descr": "A list of your meetings in descending order", "imageName": "Clipboard"]
    ])
    
    static let meetingCards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "s", "name": "Pulse Survey*", "card_type": "survey", "descr": "This required module has the survey questions used to in the company pulse chart", "imageName": "Smiley"],
        ["id" : "d", "name": "Follow Up Items", "card_type": "to_do", "descr": "Stay organized with this summary of your To Do list items", "imageName": "Todo"],
        ["id" : "n", "name": "Notes", "card_type": "notes", "descr": "Have something on your mind? Keep track of your notes here", "imageName": "DoublePaper"]
    ])
    
    static let personCards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "i", "name": "Info*", "card_type": "info", "descr": "This required modules includes contact information for your team member", "imageName": "DriverLicense"],
        ["id" : "t", "name": "Team(*)", "card_type": "team", "descr": "This module automatically displays if this team member is a manager-level (or higher) employee in the company", "imageName": "MyTeamDark"],
        ["id" : "d", "name": "Follow Up Items", "card_type": "to_do", "descr": "Stay organized with this summary of your To Do list items", "imageName": "Todo"],
        ["id" : "m", "name": "Recent Meetings", "card_type": "meetings", "descr": "A list of your meetings with this team member in descending order", "imageName": "Clipboard"],
        ["id" : "n", "name": "Notes", "card_type": "notes", "descr": "Have something on your mind? Keep track of your notes here", "imageName": "DoublePaper"]
    ]);
    
    //static let positions: [[String: String]] = [["positionId": "1", "description": "Manager"],["positionId": "2", "description": "Individual Contributor"]]
    //static let positions: [String: String] = ["Individual Contributor": "1", "Manager": "2", "Director": "3", "Vice President": "4", "CEO": "5"]
    static let positions: [String: String] = ["1": "Individual Contributor", "2": "Manager", "3": "Director", "4": "Vice President", "5": "CEO"]
}

enum AlertTypes : String {
    case alert = "Alert"
    case success = "Success"
    case failure = "Failure"
}

struct StoryboardID {
    static let dashboardNavVC = "DashboardNavVC"
    static let settingsNavVC = "SettingsNavVC"
    static let settingsVC = "SettingsVC"
    static let loginSignupVC = "LoginSignupVC"
    static let signupVC = "SignupVC"
    static let teamCollectionVC = "TeamCollectionVC"
    static let todoVC = "TodoVC"
    static let todoEditVC = "TodoEditVC"
    static let meetingSurveyVC = "MeetingSurveyVC"
}

struct SegueID {
    static let seeAllTeamList = "SeeAllTeamList"
}

struct ObjectKeys {
    
    struct Company {
        static let objectId = "objectId"
        static let companyName = "companyName"
    }
    
    struct Person {
        static let objectId = "objectId"
        static let updatedAt = "updatedAt"
        static let createdAt = "createdAt"
        static let email = "email"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let positionId = "positionId"
        static let phone = "phone"
        static let managerId = "managerId"
        static let userId = "userId"
        static let photoUrlString = "photoUrlString"
		static let photo = "photo"
        static let selectedCards = "selectedCards"
        static let deletedAt = "deletedAt"
        static let companyId = "companyId"
    }
    
    struct Meeting {
        static let objectId = "objectId"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let personId = "personId"
        static let managerId = "managerId"
        static let surveyId = "surveyId"
        static let notes = "notes"
        static let notesPhotoUrlString = "notesPhotoUrlString"
        static let notesPhotoUrl = "notesPhotoUrl"
        static let meetingDate = "meetingDate"
        static let meetingPlace = "meetingPlace"
        static let selectedCards = "selectedCards"
        static let deletedAt = "deletedAt"
    }
    
    struct ToDo {
        static let objectId = "objectId"
        static let updatedAt = "updatedAt"
        static let createdAt = "createdAt"
        static let managerId = "managerId"
        static let personId = "personId"
        static let meetingId = "meetingId"
        static let text = "text"
        static let dueAt = "dueAt"
        static let completedAt = "completedAt"
        static let deletedAt = "deletedAt"
    }
    
    struct User {
        static let objectId = "objectId"
        static let person = "person"
    }
    
    struct Survey {
        static let objectId = "objectId"
        //static let objectId = "_id"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let surveyDesc1 = "surveyDesc1"
        static let surveyValueId1 = "surveyValueId1"
        static let surveyDesc2 = "surveyDesc2"
        static let surveyValueId2 = "surveyValueId2"
        static let surveyDesc3 = "surveyDesc3"
        static let surveyValueId3 = "surveyValueId3"
        static let meetingDate = "meetingDate"
        static let personId = "personId"
        static let companyId = "companyId"
    }
}

struct CellReuseIdentifier {
    struct Team {
        static let teamCollectionCell = "TeamCollectionCell"
        static let teamListCell = "TeamListCell"
    }
    
    struct Todo {
        static let todoAddCell = "TodoAddCell"
        static let todoListCell = "TodoListCell"
        static let todoShowCompletedCell = "TodoShowCompletedCell"
        static let todoEditTextCell = "TodoEditTextCell"
        static let todoEditPersonCell = "TodoEditPersonCell"
    }
    
    struct Meeting {
        static let meetingPersonListCell = "MeetingPersonListCell"
    }
}

struct Notifications {
    struct Team {
        static let addTeamMemberSuccessful = "AddTeamMemberSuccessful"
    }
}
