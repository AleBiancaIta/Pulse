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
    }
    
    class func savePersonToParse(person: Person, withCompletion completion: PFBooleanResultBlock?) {
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
        
        parsePerson.saveInBackground(block: completion)
    }
}

/*
class Post: NSObject {
    /**
     * Other methods
     */
    
    /**
     Method to add a user post to Parse (uploading image file)
     
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
    class func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let post = PFObject(className: "Post")
        
        // Add relevant fields to the object
        post["media"] = getPFFileFromImage(image) // PFFile column type
        post["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        post["caption"] = caption
        post["likesCount"] = 0
        post["commentsCount"] = 0
        
        // Save object (following function will save the object in Parse asynchronously)
        post.saveInBackgroundWithBlock(completion)
    }
    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
}*/

