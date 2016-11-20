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
            let error = NSError(domain: "ParseClient", code: 0, userInfo: userInfo)
            completion(nil, error as Error)
        }
    }
    
    func fetchTeamMembersFor(managerId: String, completion: @escaping ([PFObject]?, Error?) -> ()) {
        let query = PFQuery(className: "Person")
        query.whereKey(ObjectKeys.Person.managerId, equalTo: managerId)
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
    
    // Order descending
    func fetchMeetingsFor(personId: String, managerId: String, orderBy: String?, limit: Int?, predicate: NSPredicate?, completion: @escaping ([PFObject]?, Error?) -> ()) {
        
        // TODO: Need to filter out deleted meetings at some point
        
        let query = PFQuery(className: "Meetings")
        
//        if let predicate = predicate {
//            query = PFQuery(className: "Meetings", predicate: predicate)
//        } else {
//            query = PFQuery(className: "Meetings")
//        }
        
        if let orderBy = orderBy {
            query.order(byDescending: orderBy)
        }
        
        if let limit = limit {
            query.limit = limit
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
}
