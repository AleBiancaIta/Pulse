//
//  Survey.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/14/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Foundation
import Parse

class Survey: NSObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    var surveyDesc1: String? // happiness
    var surveyValueId1: Int?
    var surveyDesc2: String? // engagement
    var surveyValueId2: Int?
    var surveyDesc3: String? // workload
    var surveyValueId3: Int?
    
    init(dictionary: [String: Any]) {
        objectId = dictionary[ObjectKeys.Meeting.objectId] as? String
        createdAt = dictionary[ObjectKeys.Meeting.createdAt] as? Date
        updatedAt = dictionary[ObjectKeys.Meeting.updatedAt] as? Date
        
        surveyDesc1 = dictionary[ObjectKeys.Survey.surveyDesc1] as? String
        surveyValueId1 = dictionary[ObjectKeys.Survey.surveyValueId1] as? Int
        surveyDesc2 = dictionary[ObjectKeys.Survey.surveyDesc2] as? String
        surveyValueId2 = dictionary[ObjectKeys.Survey.surveyValueId2] as? Int
        surveyDesc3 = dictionary[ObjectKeys.Survey.surveyDesc3] as? String
        surveyValueId3 = dictionary[ObjectKeys.Survey.surveyValueId3] as? Int
    }
    
    class func saveSurveyToParse(survey: Survey, withCompletion completion: PFBooleanResultBlock?) {
        let parseSurvey = PFObject(className: "Survey")
        
        // Add relevant fields to the object
        parseSurvey[ObjectKeys.Survey.surveyDesc1] = survey.surveyDesc1
        parseSurvey[ObjectKeys.Survey.surveyValueId1] = survey.surveyValueId1
        parseSurvey[ObjectKeys.Survey.surveyDesc2] = survey.surveyDesc2
        parseSurvey[ObjectKeys.Survey.surveyValueId2] = survey.surveyValueId2
        parseSurvey[ObjectKeys.Survey.surveyDesc3] = survey.surveyDesc3
        parseSurvey[ObjectKeys.Survey.surveyValueId3] = survey.surveyValueId3
        
        parseSurvey.saveInBackground(block: completion)
    }
}
