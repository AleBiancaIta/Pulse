//
//  ParseClient.swift
//  Pulse
//
//  Created by Itasari on 11/14/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class ParseClient: NSObject {
    
    // MARK: - Properties
    
    //var currentUser = PFUser.current()
    //var currentPerson: Person

    // MARK: - Shared instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    func getCurrentPerson(completion: @escaping (PFObject?, Error?) -> ()) {
        if let currentUser = PFUser.current() {
            let query = PFQuery(className: "Person")
            query.whereKey(ObjectKeys.Person.userId, equalTo: currentUser.objectId!)
            query.findObjectsInBackground(block: { (persons: [PFObject]?, error: Error?) in
                if let error = error {
                    debugPrint("unable to find current person")
                    completion(nil, error)
                } else {
                    if let persons = persons {
                        if persons.count > 0 {
                            let person = persons[0]
                            debugPrint("person is \(person)")
                            completion(person, nil)
                        }
                    }
                }
            })
        } else {
            let userInfo = [NSLocalizedDescriptionKey: "currentUser is nil"]
            let error = NSError(domain: "ParseClient", code: 0, userInfo: userInfo) as Error
            completion(nil, error)
        }
    }
    
    func fetchPersonFor(personId: String, completion: @escaping (PFObject?, Error?) -> ()) {
        let query = PFQuery(className: "Person")
        query.whereKey(ObjectKeys.Person.objectId, equalTo: personId)
        query.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
            if let error = error {
                completion(nil, error)
            } else {
                if let persons = persons, persons.count > 0 {
                    let person = persons[0]
                    completion(person, nil)
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "fetchPerson query returns no person with id: \(personId)"]
                    let error = NSError(domain: "ParseClient fetchPersonFor", code: 0, userInfo: userInfo) as Error
                    completion(nil, error)
                }
            }
        }
    }
    
    func fetchTeamMembersFor(managerId: String, isAscending1: Bool?, isAscending2: Bool?, orderBy1: String?, orderBy2: String?, isDeleted: Bool, completion: @escaping ([PFObject]?, Error?) -> ()) {
        let query = PFQuery(className: "Person")
        query.whereKey(ObjectKeys.Person.managerId, equalTo: managerId)
        
        if let isAscending1 = isAscending1, let orderBy1 = orderBy1 {
            if isAscending1 {
                query.order(byAscending: orderBy1)
            } else {
                query.order(byDescending: orderBy1)
            }
        }
        
        if let isAscending2 = isAscending2, let orderBy2 = orderBy2 {
            if isAscending2 {
                query.order(byAscending: orderBy2)
            } else {
                query.order(byDescending: orderBy2)
            }
        }
        
        if isDeleted {
            query.whereKeyExists(ObjectKeys.Person.deletedAt)
        } else {
            query.whereKeyDoesNotExist(ObjectKeys.Person.deletedAt)
        }
        
        query.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
            if let error = error {
                debugPrint("Unable to fetch team members for managerId: \(managerId)")
                completion(nil, error)
            } else {
                if let persons = persons {
                    completion(persons, nil)
                }
            }
        }
    }
    
    func fetchMeetingFor(meetingId: String, completion: @escaping (PFObject?, Error?) -> ()) {
        let query = PFQuery(className: "Meetings")
        query.whereKey(ObjectKeys.Meeting.objectId, equalTo: meetingId)
        query.findObjectsInBackground { (meetings: [PFObject]?, error: Error?) in
            if let error = error {
                completion(nil, error)
            } else {
                if let meetings = meetings, meetings.count > 0 {
                    let meeting = meetings[0]
                    completion(meeting, nil)
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "fetchMeetingForMeetingId query returns no meeting with id: \(meetingId)"]
                    let error = NSError(domain: "ParseClient fetchMeetingFor", code: 0, userInfo: userInfo) as Error
                    completion(nil, error)
                }
            }
        }
    }
    
    // Order descending
    func fetchMeetingsFor(personId: String, managerId: String, meetingDate: Date?, orderBy: String?, limit: Int?, isDeleted: Bool, predicate: NSPredicate?, completion: @escaping ([PFObject]?, Error?) -> ()) {
        
        // TODO: Need to filter out deleted meetings at some point
        
        let query = PFQuery(className: "Meetings")
        
//        if let predicate = predicate {
//            query = PFQuery(className: "Meetings", predicate: predicate)
//        } else {
//            query = PFQuery(className: "Meetings")
//        }
        
        if let meetingDate = meetingDate {
            query.whereKey(ObjectKeys.Meeting.meetingDate, equalTo: meetingDate)
        }
        
        if let orderBy = orderBy {
            query.order(byDescending: orderBy)
        }
        
        if let limit = limit {
            query.limit = limit
        }
        
        if isDeleted {
            query.whereKeyExists(ObjectKeys.Meeting.deletedAt)
        } else {
            query.whereKeyDoesNotExist(ObjectKeys.Meeting.deletedAt)
        }
        
        query.whereKey(ObjectKeys.Meeting.personId, equalTo: personId)
        query.whereKey(ObjectKeys.Meeting.managerId, equalTo: managerId)
        query.findObjectsInBackground { (meetings: [PFObject]?, error: Error?) in
            debugPrint("query is \(query)")
            if let error = error {
                debugPrint("Unable to fetch meetings for person: \(personId), manager: \(managerId)")
                completion(nil, error)
            } else {
                if let meetings = meetings {
                    debugPrint("Find meetings, \(meetings.count)")
                    completion(meetings, nil)
                }
            }
        }
    }
    
    func saveNewCompanyToParse(company: Company, completion: PFBooleanResultBlock?) {
        let parseCompany = PFObject(className: "Company")
        parseCompany[ObjectKeys.Company.companyName] = company.companyName
        parseCompany.saveInBackground(block: completion)
    }
    
    func fetchCompaniesFor(company: Company, completion: @escaping ([PFObject]?, Error?) -> ()) {
        let query = PFQuery(className: "Company")
        query.whereKey(ObjectKeys.Company.companyName, equalTo: company.companyName)
        query.findObjectsInBackground { (companies: [PFObject]?, error: Error?) in
            if let error = error {
                debugPrint("Unable to fetch companies for company: \(company.companyName)")
                completion(nil, error)
            } else {
                if let companies = companies {
                    debugPrint("Query returns \(companies.count) companies")
                    completion(companies, nil)
                }
            }
        }
    }
    
    func saveTodoToParse(todo: PFObject, completion: PFBooleanResultBlock?) {
        todo.saveInBackground(block: completion)
    }
    
    func fetchTodoFor(managerId: String, personId: String?, meetingId: String?, limit: Int?, isAscending: Bool?, orderBy: String?, isDeleted: Bool, isCompleted: Bool, completion: @escaping ([PFObject]?, Error?) -> ()) {
        let query = PFQuery(className: "ToDo")
        query.whereKey(ObjectKeys.ToDo.managerId, equalTo: managerId)
        
        if let personId = personId {
            query.whereKey(ObjectKeys.ToDo.personId, equalTo: personId)
        }
        
        if let meetingId = meetingId {
            query.whereKey(ObjectKeys.ToDo.meetingId, equalTo: meetingId)
        }
        
        if let limit = limit {
            query.limit = limit
        }
        
        if let isAscending = isAscending, let orderBy = orderBy {
            if isAscending {
                query.order(byAscending: orderBy)
            } else {
                query.order(byDescending: orderBy)
            }
        }
        
        if isDeleted {
            query.whereKeyExists(ObjectKeys.ToDo.deletedAt)
        } else {
            query.whereKeyDoesNotExist(ObjectKeys.ToDo.deletedAt)
        }
        
        if isCompleted {
            query.whereKeyExists(ObjectKeys.ToDo.completedAt)
        } else {
            query.whereKeyDoesNotExist(ObjectKeys.ToDo.completedAt)
        }
        
        query.findObjectsInBackground { (todoItems: [PFObject]?, error: Error?) in
            if let error = error {
                debugPrint("Unable to fetch todoItems")
                completion(nil, error)
            } else {
                if let todoItems = todoItems {
                    debugPrint("Query returns \(todoItems.count) items")
                    completion(todoItems, nil)
                }
            }
        }
    }

	func fetchPersonFor(email: String, completion: @escaping (PFObject?, Error?) -> ()) {
		let query = PFQuery(className: "Person")
		query.whereKey(ObjectKeys.Person.email, equalTo: email)
		query.findObjectsInBackground { (persons: [PFObject]?, error: Error?) in
			if let error = error {
				completion(nil, error)
			} else {
				if let persons = persons, persons.count > 0 {
					let person = persons[0]
					completion(person, nil)
				} else {
					let userInfo = [NSLocalizedDescriptionKey: "fetchPerson query returns no person with email: \(email)"]
					let error = NSError(domain: "ParseClient fetchPersonFor", code: 0, userInfo: userInfo) as Error
					completion(nil, error)
				}
			}
		}
	}
}
