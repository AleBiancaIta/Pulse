//
//  Card.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/9/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class Card: NSObject {

    var id: String?
    var name: String?
    var cardType: String?
    //var pageType: String? TODO remove??
    
    init(dictionary: [String: String]) {
        if let id = dictionary["id"] {
            self.id = id
        }
        if let name = dictionary["name"] {
            self.name = name
        }
        if let cardType = dictionary["card_type"] {
            self.cardType = cardType
        }
        /*if let pageType = dictionary["page_type"] {
            self.pageType = pageType
        }*/
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
