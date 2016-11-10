//
//  Card.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class Card: NSObject {

    //var index: String? // TODO add this?
    var id: String? // TODO change to enum?
    var name: String?
    
    static let cards: [Card] = [
        Card(dictionary: ["id" : "meetings", "name": "Meetings"]),
        Card(dictionary: ["id" : "org_chart", "name": "Organizational Chart"]),
        Card(dictionary: ["id" : "photo_notes", "name": "Photo Notes"]),
        Card(dictionary: ["id" : "pulse_graph", "name": "Pulse Graph"]),
        Card(dictionary: ["id" : "team", "name": "Team"]),
        Card(dictionary: ["id" : "to_do", "name": "To Dos"])
    ]
    
    init(dictionary: [String: String]) {
        id = dictionary["id"]
        name = dictionary["name"]
    }
    
    class func cardsWithArray(dictionaries: [ [String: String] ]) -> [Card] {
        var cardsArray: [Card] = []
        
        for dictionary in dictionaries {
            let card = Card(dictionary: dictionary)
            cardsArray.append(card)
        }
        
        return cardsArray
    }

}
