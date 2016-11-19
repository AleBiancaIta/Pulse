//
//  Company.swift
//  Pulse
//
//  Created by Itasari on 11/18/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class Company: NSObject {
    
    // MARK: - Properties
    var objectId: String?
    var companyName: String
    
    init(companyName: String) {
        self.companyName = companyName
    }
}
