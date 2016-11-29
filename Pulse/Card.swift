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
    var descr: String?
    
    init(dictionary: [String: String]) {
        if let id = dictionary["id"] {
            self.id = id
        }
        if let name = dictionary["name"] {
            self.name = name
        }
        if let descr = dictionary["descr"] {
            self.descr = descr
        }
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
