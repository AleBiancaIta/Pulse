//
//  Meeting.swift
//  Pulse
//
//  Created by Itasari on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Foundation
import Parse

class Meeting: NSObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    var personId: String
    var managerId: String
    var surveyId: String
    var notes: String?
    var notesPhotoUrlString: String?
    var notesPhotoUrl: URL?
    var meetingDate: Date
    var meetingPlace: String?
    var selectedCards: String?
    var deletedAt: Date?
    
    init(dictionary: [String: Any]) {
        objectId = dictionary[ObjectKeys.Meeting.objectId] as? String
        createdAt = dictionary[ObjectKeys.Meeting.createdAt] as? Date
        updatedAt = dictionary[ObjectKeys.Meeting.updatedAt] as? Date
        personId = dictionary[ObjectKeys.Meeting.personId] as! String
        managerId = dictionary[ObjectKeys.Meeting.managerId] as! String
        surveyId = dictionary[ObjectKeys.Meeting.surveyId] as! String
        notes = dictionary[ObjectKeys.Meeting.notes] as? String
    
        if let notesPhotoUrlString = dictionary[ObjectKeys.Meeting.notesPhotoUrlString] as? String {
            self.notesPhotoUrlString = notesPhotoUrlString
            
            if let photoUrl = URL(string: notesPhotoUrlString) {
                self.notesPhotoUrl = photoUrl
            }
        }
        
        meetingDate = dictionary[ObjectKeys.Meeting.meetingDate] as! Date
        meetingPlace = dictionary[ObjectKeys.Meeting.meetingPlace] as? String
        selectedCards = dictionary[ObjectKeys.Meeting.selectedCards] as? String
        deletedAt = dictionary[ObjectKeys.Meeting.deletedAt] as? Date
    }
    
    class func saveMeetingToParse(meeting: Meeting, withCompletion completion: PFBooleanResultBlock?) {
        let parseMeeting = PFObject(className: "Meeting")
        
        // Add relevant fields to the object
        parseMeeting[ObjectKeys.Meeting.personId] = meeting.personId
        parseMeeting[ObjectKeys.Meeting.managerId] = meeting.managerId
        parseMeeting[ObjectKeys.Meeting.surveyId] = meeting.surveyId
        parseMeeting[ObjectKeys.Meeting.meetingDate] = meeting.meetingDate
        
        if let notes = meeting.notes {
            parseMeeting[ObjectKeys.Meeting.notes] = notes
        }
        
        if let notesPhotoUrlString = meeting.notesPhotoUrlString {
            parseMeeting[ObjectKeys.Meeting.notesPhotoUrlString] = notesPhotoUrlString
        }
        
        if let notesPhotoUrl = meeting.notesPhotoUrl {
            parseMeeting[ObjectKeys.Meeting.notesPhotoUrl] = notesPhotoUrl
        }
        
        if let meetingPlace = meeting.meetingPlace {
            parseMeeting[ObjectKeys.Meeting.meetingPlace] = meetingPlace
        }

        if let selectedCards = meeting.selectedCards {
            parseMeeting[ObjectKeys.Meeting.selectedCards] = selectedCards
        }

        if let deletedAt = meeting.deletedAt {
            parseMeeting[ObjectKeys.Meeting.deletedAt] = deletedAt
        }
        
        parseMeeting.saveInBackground(block: completion)
    }
    
    /* TODO fix - code doesn't compile when this is uncommented. why?
     class func meetingsWithArray(dictionaries: [PFObject]) -> [Meeting] {
        let meetingsArray: [Meeting] = []
        
        for pfObject in dictionaries {
            let dictionary = [
                "objectId": pfObject["_id"],
                "createdAt": pfObject["_created_at"],
                "updatedAt": pfObject["_updated_at"],
                
                "personId": pfObject["personId"],
                "managerId": pfObject["managerId"],
                "surveyId": pfObject["surveyId"],
                "notes": pfObject["notes"],
                "notesPhotoUrlString": pfObject["notesPhotoUrlString"],
                "notesPhotoUrl": pfObject["meetingDate"],
                "meetingPlace": pfObject["meetingPlace"],
                "selectedCards": pfObject["selectedCards"],
                "deletedAt": pfObject["deletedAt"],
            ]
            let meeting = Meeting(dictionary: dictionary)
            meetingsArray.append(meeting)
        }
        
        return meetingsArray
    }*/

    
    // Fetch functions
    // query.getObjectInBackgroundWithId:block
    // query.findObjectsInBackgroundWithBlock:
    // query = PFQuery(className:,predicate:)
}
