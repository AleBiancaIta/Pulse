//
//  Person.swift
//  Pulse
//
//  Created by Itasari on 11/12/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Foundation
import Parse

class Person: NSObject {
    var firstName: String
    var lastName: String
    var positionId: String // either manager or I.C
    var email: String?
    var phone: String?
    var managerId: String?
    var userId: String?
    var photoUrlString: String?
    var photoUrl: URL?
    var selectedCards: String?
    var deletedAt: Date?
	var photo: Data?
    var pfObject: PFObject? // TODO: need to figure out how to do this better
    var companyId: String?
    var positionDesc: String?

    // TODO - this needs to be changed later since positionId is not always 2
	init(firstName: String, lastName: String) {
		self.firstName = firstName
		self.lastName = lastName
		self.positionId = "1"
	}

    init(dictionary: [String: Any]) {
        firstName = dictionary[ObjectKeys.Person.firstName] as! String
        lastName = dictionary[ObjectKeys.Person.lastName] as! String
        positionId = dictionary[ObjectKeys.Person.positionId] as! String

        email = dictionary[ObjectKeys.Person.email] as? String
        phone = dictionary[ObjectKeys.Person.phone] as? String
        managerId = dictionary[ObjectKeys.Person.managerId] as? String
        userId = dictionary[ObjectKeys.Person.userId] as? String

        if let photoUrlString = dictionary[ObjectKeys.Person.photoUrlString] as? String {
            self.photoUrlString = photoUrlString

            if let photoUrl = URL(string: photoUrlString) {
                self.photoUrl = photoUrl
            }
        }

        selectedCards = dictionary[ObjectKeys.Person.selectedCards] as? String
        deletedAt = dictionary[ObjectKeys.Person.deletedAt] as? Date
		photo = dictionary[ObjectKeys.Person.photo] as? Data
        companyId = dictionary[ObjectKeys.Person.companyId] as? String
        positionDesc = dictionary[ObjectKeys.Person.positionDesc] as? String
    }

    class func savePersonToParse(person: Person, withCompletion completion: PFBooleanResultBlock?) {
        
        // TODO: have a check if it's a current user or team member, we need to handle
        // the managerId or userId field population here
        // Maybe separate this function into saveUser and saveTeamMember
        // update positionId, managerId, and userId
        
        let parsePerson = PFObject(className: "Person")
        
        // Add relevant fields to the object
        parsePerson[ObjectKeys.Person.firstName] = person.firstName
        parsePerson[ObjectKeys.Person.lastName] = person.lastName
        parsePerson[ObjectKeys.Person.positionId] = person.positionId
        
        if let email = person.email {
            parsePerson[ObjectKeys.Person.email] = email
        }

        if let phone = person.phone {
            parsePerson[ObjectKeys.Person.phone] = phone
        }
        
        if let managerId = person.managerId {
            parsePerson[ObjectKeys.Person.managerId] = managerId
        }
        
        if let userId = person.userId {
            parsePerson[ObjectKeys.Person.userId] = userId
        }
        
        if let photoUrlString = person.photoUrlString {
            parsePerson[ObjectKeys.Person.photoUrlString] = photoUrlString
        }
        
        if let selectedCards = person.selectedCards {
            parsePerson[ObjectKeys.Person.selectedCards] = selectedCards
        }
        
        if let deletedAt = person.deletedAt {
            parsePerson[ObjectKeys.Person.deletedAt] = deletedAt
        }

		if let companyId = person.companyId {
			parsePerson[ObjectKeys.Person.companyId] = companyId
		}
        
        if let positionDesc = person.positionDesc {
            parsePerson[ObjectKeys.Person.positionDesc] = positionDesc
        }

        if let photo = person.photo {
			savePhotoInPerson(parsePerson: parsePerson, photo: photo, withCompletion: completion)
        }
		else {
			parsePerson.saveInBackground(block: completion)
		}
    }

	class func savePhotoInPerson(parsePerson: PFObject, photo: Data, withCompletion completion: PFBooleanResultBlock?) {

		let parsePhotoFile = PFFile(data: photo)
		parsePhotoFile?.saveInBackground(block: { (success: Bool, error: Error?) in
			if success {
				parsePerson[ObjectKeys.Person.photo] = parsePhotoFile
			}
			else {
				print(error!.localizedDescription);
			}
			parsePerson.saveInBackground(block: completion)
		})
	}
}
