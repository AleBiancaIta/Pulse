//
//  Constants.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Foundation

enum CardType: Int {
    case meetings = 0, org_chart, photo_notes, pulse_graph, team, to_do
    static var count: Int { return CardType.to_do.hashValue + 1}
}

enum PageType: Int {
    case dashboard = 0, meeting, person
    static var count: Int { return PageType.person.hashValue + 1}
}

class Constants: NSObject {

    static let cards: [Card] = Card.cardsWithArray(dictionaries: [
        ["id" : "m" as AnyObject, "name": "Meetings" as AnyObject, "card_type": CardType.meetings as AnyObject, "page_type": "dashboard" as AnyObject],
        ["id" : "o" as AnyObject, "name": "Organizational Chart" as AnyObject, "type": "dashboard" as AnyObject],
        ["id" : "n" as AnyObject, "name": "Photo Notes" as AnyObject, "type": "dashboard" as AnyObject],
        ["id" : "g" as AnyObject, "name": "Pulse Graph" as AnyObject, "type": "dashboard" as AnyObject],
        ["id" : "t" as AnyObject, "name": "Team" as AnyObject, "type": "dashboard" as AnyObject],
        ["id" : "d" as AnyObject, "name": "To Dos" as AnyObject, "type": "dashboard" as AnyObject]
    ])
}
