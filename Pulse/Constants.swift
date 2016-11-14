//
//  Constants.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Foundation

/*enum CardType: Int {
    case meeting = 0, org_chart, photo_notes, pulse_graph, team, to_do
    static var count: Int { return CardType.to_do.hashValue + 1}
}

enum PageType: Int {
    case dashboard = 0, meeting, person
    static var count: Int { return PageType.person.hashValue + 1}
}*/

class Constants: NSObject {

    /*static let cards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "m" as AnyObject, "name": "Meetings" as AnyObject, "card_type": CardType(rawValue: 0) as AnyObject, "page_type": PageType.dashboard as AnyObject],
        ["id" : "o" as AnyObject, "name": "Organizational Chart" as AnyObject, "card_type": CardType.org_chart as AnyObject, "page_type": PageType.dashboard as AnyObject],
        ["id" : "n" as AnyObject, "name": "Photo Notes" as AnyObject, "card_type": CardType.photo_notes as AnyObject, "page_type": PageType.dashboard as AnyObject],
        ["id" : "g" as AnyObject, "name": "Pulse Graph" as AnyObject, "card_type": CardType.pulse_graph as AnyObject, "page_type": PageType.dashboard as AnyObject],
        ["id" : "t" as AnyObject, "name": "Team" as AnyObject, "card_type": CardType.team as AnyObject, "page_type": PageType.dashboard as AnyObject],
        ["id" : "d" as AnyObject, "name": "To Dos" as AnyObject, "card_type": CardType.to_do as Any as AnyObject, "page_type": PageType.dashboard as AnyObject]
    ])*/
    static let dashboardCards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "m", "name": "Meetings", "card_type": "meeting", "page_type": "dashboard"],
        // TODO optional for now ["id" : "o", "name": "Organizational Chart", "card_type": "org_chart", "page_type": "dashboard"],
        ["id" : "g" , "name": "Pulse Graph", "card_type": "pulse_graph", "page_type": "dashboard"],
        ["id" : "t", "name": "Team", "card_type": "team", "page_type": "dashboard"],
        ["id" : "d", "name": "To Dos", "card_type": "to_do", "page_type": "dashboard"]
    ])
    
    static let meetingCards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "n", "name": "Notes", "card_type": "notes", "page_type": "meeting"],
        ["id" : "p", "name": "Photo Notes", "card_type": "photo_note", "page_type": "meeting"],
        ["id" : "d", "name": "To Dos", "card_type": "to_do", "page_type": "meeting"]
    ])
    
    //static let positions: [[String: String]] = [["positionId": "1", "description": "Manager"],["positionId": "2", "description": "Individual Contributor"]]
    static let positions: [String: String] = ["1": "Manager", "2": "Individual Contributor"]
}

struct StoryboardID {
    static let dashboardNavVC = "DashboardNavVC"
    static let settingsNavVC = "SettingsNavVC"
    static let settingsVC = "SettingsVC"
    static let loginSignupVC = "LoginSignupVC"
    static let signupVC = "SignupVC"
    static let teamCollectionVC = "TeamCollectionVC"
}

struct ObjectKeys {
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
        static let selectedCards = "selectedCards"
        static let deletedAt = "deletedAt"
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
        static let person = "Person"
    }
}

struct CellReuseIdentifier {
    struct Team {
        static let teamCollectionCell = "TeamCollectionCell"
        static let teamListCell = "TeamListCell"
    }
}

struct Notifications {
    struct Team {
        static let addTeamMemberSuccessful = "AddTeamMemberSuccessful"
    }
}
