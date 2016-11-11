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
    static let cards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "m", "name": "Meetings", "card_type": "meeting", "page_type": "dashboard"],
        ["id" : "o", "name": "Organizational Chart", "card_type": "org_chart", "page_type": "dashboard"],
        ["id" : "n", "name": "Photo Notes", "card_type": "photo_note", "page_type": "dashboard"],
        ["id" : "g" , "name": "Pulse Graph", "card_type": "pulse_graph", "page_type": "dashboard"],
        ["id" : "t", "name": "Team", "card_type": "team", "page_type": "dashboard"],
        ["id" : "d", "name": "To Dos", "card_type": "to_do", "page_type": "dashboard"]
    ])
}
