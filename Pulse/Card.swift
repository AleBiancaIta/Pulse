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
    var cardType: CardType?
    var pageType: PageType?
    var view: UIView?
    
    init(dictionary: [String: AnyObject]) {
        if let id = dictionary["id"] as? String {
            self.id = id
        }
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        if let cardType = dictionary["card_type"] as? CardType {
            self.cardType = cardType
        }
        if let pageType = dictionary["page_type"] as? PageType {
            self.pageType = pageType
        }
        if let view = dictionary["view"] as? UIView {
            self.view = view
        }
    }
    
    class func cardsWithArray(dictionaries: [ [String: AnyObject] ]) -> [Card] {
        var cardsArray: [Card] = []
        
        for dictionary in dictionaries {
            let card = Card(dictionary: dictionary)
            cardsArray.append(card)
        }
        
        return cardsArray
    }
}
