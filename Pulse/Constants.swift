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
        ["id" : "m", "name": "Meetings", "card_type": "meetings", "page_type": "dashboard"],
        ["id" : "g" , "name": "Pulse Graph", "card_type": "pulse_graph", "page_type": "dashboard"],
        ["id" : "t", "name": "Team Members", "card_type": "team", "page_type": "dashboard"],
        ["id" : "d", "name": "To Dos", "card_type": "to_do", "page_type": "dashboard"]
    ])
    
    static let meetingCards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "d", "name": "To Dos", "card_type": "to_do", "page_type": "meeting"],
        ["id" : "n", "name": "Notes", "card_type": "notes", "page_type": "meeting"],
        ["id" : "p", "name": "Photo Notes", "card_type": "photo_note", "page_type": "meeting"]
    ])
    
    //static let positions: [[String: String]] = [["positionId": "1", "description": "Manager"],["positionId": "2", "description": "Individual Contributor"]]
    static let positions: [String: String] = ["Individual Contributor": "1", "Manager": "2", "Director": "3", "Vice President": "4", "CEO": "5"]
}

struct StoryboardID {
    static let dashboardNavVC = "DashboardNavVC"
    static let settingsNavVC = "SettingsNavVC"
    static let settingsVC = "SettingsVC"
    static let loginSignupVC = "LoginSignupVC"
    static let signupVC = "SignupVC"
    static let teamCollectionVC = "TeamCollectionVC"
    static let todoVC = "TodoVC"
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
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let surveyDesc1 = "surveyDesc1"
        static let surveyValueId1 = "surveyValueId1"
        static let surveyDesc2 = "surveyDesc2"
        static let surveyValueId2 = "surveyValueId2"
        static let surveyDesc3 = "surveyDesc3"
        static let surveyValueId3 = "surveyValueId3"
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
    }
}

struct Notifications {
    struct Team {
        static let addTeamMemberSuccessful = "AddTeamMemberSuccessful"
    }
}
